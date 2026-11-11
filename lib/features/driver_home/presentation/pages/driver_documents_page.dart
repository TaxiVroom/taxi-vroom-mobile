import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/document_card.dart';
import 'package:mobile/core/widgets/document_photo_slot.dart';
import 'package:mobile/core/widgets/expiry_date_field.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

// What the driver sends for one document type.
typedef DocumentSending = ({
  String documentTypeId,
  String frontFilePath,
  String? backFilePath,
  DateTime? expiresAt,
});

/// "Vos documents": the state of each document type, from the API. Opened
/// when a document blocks going online, from the home's banner and from the
/// "Compte" tab. Spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
class DriverDocumentsPage extends StatelessWidget {
  const DriverDocumentsPage({
    required this.documents,
    required this.onPostponed,
    required this.onSent,
    this.isSubmitting = false,
    this.failureMessage,
    this.closeLabel = 'Plus tard',
    this.canPostpone = true,
    this.sendingTypeId,
    this.isRefreshing = false,
    super.key,
  });

  // Read again: a loader instead of the old states, only the title and the
  // close button stay.
  final bool isRefreshing;

  // The document being sent: its card shows a spinner, as at the
  // registration.
  final String? sendingTypeId;

  // False when a document blocks: only sending it is offered.
  final bool canPostpone;

  final DriverDocuments documents;
  final VoidCallback onPostponed;
  final ValueChanged<DocumentSending> onSent;
  final bool isSubmitting;
  final String? failureMessage;

  // "Plus tard" when blocked out of going online, "Retour" from the account.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final hasToSend = documents.documents.any(_canSend);
    return Scaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Vos documents',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              if (isRefreshing)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                const SizedBox(height: 4),
                Text(_summary, style: const TextStyle(color: AppColors.muted)),
                // As at the registration: each document to send opens from
                // its own line, however many there are.
                if (hasToSend) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Touchez un document à envoyer pour l’ajouter.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
                if (failureMessage case final message?) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      for (final (index, document)
                          in documents.documents.indexed) ...[
                        if (index > 0) const SizedBox(height: 12),
                        _buildDocument(context, document),
                      ],
                    ],
                  ),
                ),
              ],
              if (canPostpone) ...[
                const SizedBox(height: 8),
                SecondaryButton(
                  // Disabled while a document is being sent (decision of the
                  // user, 2026-11-11).
                  onPressed: sendingTypeId == null ? onPostponed : null,
                  alignment: Alignment.center,
                  child: Text(closeLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // "3 sur 4 en règle. Un document bloque la conduite."
  String get _summary {
    final count =
        '${documents.validatedCount} sur ${documents.documents.length} '
        'en règle.';
    if (!documents.needsAction) return '$count Tout est à jour.';
    final problem = documents.blocksDriving
        ? 'Un document vous empêche de passer en ligne.'
        : 'Un document est à envoyer bientôt.';
    return '$count $problem';
  }

  // Only a document to renew, to provide, expired or missing can be sent;
  // one in order, or waiting for the admin, is not clickable at all
  // (decision of the user, 2026-11-10).
  bool _canSend(DriverDocument document) =>
      document.needsAction && !document.inReview;

  // The registration's card ("Mes documents"), as the user asked: "+" to
  // send, a spinner while sending, a check once in order or sent.
  Widget _buildDocument(BuildContext context, DriverDocument document) {
    final colorScheme = Theme.of(context).colorScheme;
    final canSend = _canSend(document);
    final isSending = document.documentTypeId == sendingTypeId;
    final (label, color, background) = _badge(document, isSending);
    final action = _action(canSend: canSend, isSending: isSending);
    final (actionColor, actionBackground) = canSend || isSending
        ? (colorScheme.primary, colorScheme.primary.withValues(alpha: 0.12))
        : (color, background);
    return DocumentCard(
      name: document.name,
      detail: _detail(document),
      badge: DocumentCardBadge(
        label: label,
        background: background,
        foreground: color,
      ),
      action: action,
      actionColor: actionColor,
      actionBackground: actionBackground,
      onTap: canSend && !isSubmitting
          ? () => _openSending(context, document)
          : null,
      borderColor: canSend ? null : Colors.transparent,
    );
  }

  DocumentCardAction _action({
    required bool canSend,
    required bool isSending,
  }) {
    if (isSending) return DocumentCardAction.sending;
    if (canSend) return DocumentCardAction.add;
    return DocumentCardAction.done;
  }

  (String, Color, Color) _badge(DriverDocument document, bool isSending) {
    if (isSending) {
      return ('ENVOI...', AppColors.muted, AppColors.border);
    }
    if (document.inReview) {
      return ('EN VÉRIFICATION', AppColors.muted, AppColors.border);
    }
    return switch (document.status) {
      DriverDocumentStatus.validated => (
        'EN RÈGLE',
        AppColors.success,
        AppColors.successBackground,
      ),
      DriverDocumentStatus.expiringSoon => (
        'À RENOUVELER',
        AppColors.warning,
        AppColors.warningBackground,
      ),
      DriverDocumentStatus.toProvide => (
        'À FOURNIR',
        AppColors.warning,
        AppColors.warningBackground,
      ),
      DriverDocumentStatus.expired => (
        'EXPIRÉ',
        AppColors.danger,
        AppColors.dangerBackground,
      ),
      DriverDocumentStatus.missing => (
        'MANQUANT',
        AppColors.danger,
        AppColors.dangerBackground,
      ),
    };
  }

  // "Valable jusqu'au 11 mars 2027 inclus", "À fournir avant le 1 mars 2027".
  String _detail(DriverDocument document) {
    final requiredFrom = document.requiredFrom;
    final lastValidDay = document.lastValidDay;
    if (document.status == DriverDocumentStatus.toProvide &&
        requiredFrom != null) {
      return 'À fournir avant le ${formatDateWithYear(requiredFrom.toLocal())}';
    }
    if (document.status == DriverDocumentStatus.missing) {
      return 'Obligatoire pour passer en ligne';
    }
    if (lastValidDay == null) return "Pas de date d'expiration";
    final day = formatDateWithYear(lastValidDay);
    if (document.status == DriverDocumentStatus.expired) {
      return 'Valable jusqu’au $day';
    }
    return 'Valable jusqu’au $day inclus';
  }

  void _openSending(BuildContext context, DriverDocument document) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DocumentSendingSheet(document: document, onSent: onSent),
    );
  }
}

class _DocumentSendingSheet extends StatefulWidget {
  const _DocumentSendingSheet({required this.document, required this.onSent});

  final DriverDocument document;
  final ValueChanged<DocumentSending> onSent;

  @override
  State<_DocumentSendingSheet> createState() => _DocumentSendingSheetState();
}

class _DocumentSendingSheetState extends State<_DocumentSendingSheet> {
  String? _front;
  String? _back;
  DateTime? _expiresAt;

  bool get _canSend {
    final document = widget.document;
    if (_front == null) return false;
    if (document.backRequired && _back == null) return false;
    return !document.expires || _expiresAt != null;
  }

  Future<void> _pick({required bool isFront}) async {
    final side = isFront ? 'Recto' : 'Verso';
    final path = await pickDocumentPhoto(
      hint: '$side — ${widget.document.name}',
    );
    if (path == null) return;
    setState(() => isFront ? _front = path : _back = path);
  }

  void _send() {
    widget.onSent((
      documentTypeId: widget.document.documentTypeId,
      frontFilePath: _front!,
      backFilePath: _back,
      expiresAt: _expiresAt,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            document.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Le document actuel reste valable jusqu’à la validation du '
            'nouveau.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DocumentPhotoSlot(
                  label: 'RECTO',
                  capturedFilePath: _front,
                  onTap: () => _pick(isFront: true),
                ),
              ),
              if (document.backRequired) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: DocumentPhotoSlot(
                    label: 'VERSO',
                    capturedFilePath: _back,
                    onTap: () => _pick(isFront: false),
                  ),
                ),
              ],
            ],
          ),
          if (document.expires) ...[
            const SizedBox(height: 20),
            ExpiryDateField(
              value: _expiresAt,
              onChanged: (date) => setState(() => _expiresAt = date),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: _canSend ? _send : null,
            alignment: Alignment.center,
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
