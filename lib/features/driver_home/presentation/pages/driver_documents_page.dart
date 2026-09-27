import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 1: shown at login when a document must be sent, and from
/// the "Compte" tab at any time.
class DriverDocumentsPage extends StatelessWidget {
  const DriverDocumentsPage({
    required this.documents,
    required this.onPostponed,
    this.closeLabel = 'Plus tard',
    super.key,
  });

  final DriverDocuments documents;
  final VoidCallback onPostponed;

  // "Plus tard" at login, "Retour" from the account.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final nextToProvide = documents.nextToProvide;
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
              const SizedBox(height: 4),
              Text(
                _summary,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final document in documents.documents)
                      _buildDocument(document),
                  ],
                ),
              ),
              // Sending a document is not built yet.
              if (nextToProvide != null)
                PrimaryButton(
                  onPressed: () {},
                  alignment: Alignment.center,
                  child: Text('Envoyer ${nextToProvide.proofName}'),
                ),
              if (!documents.blocksDriving) ...[
                const SizedBox(height: 8),
                SecondaryButton(
                  onPressed: onPostponed,
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

  // "5 sur 6 validés. Un document expire bientôt."
  String get _summary {
    final count =
        '${documents.validatedCount} sur ${documents.documents.length} '
        'validés.';
    if (!documents.needsAction) return '$count Tout est à jour.';
    final problem = documents.blocksDriving
        ? 'Envoyez-le pour pouvoir conduire.'
        : 'Un document expire bientôt.';
    return '$count $problem';
  }

  Widget _buildDocument(DriverDocument document) {
    final (label, color, background) = switch (document.status) {
      DriverDocumentStatus.validated => (
        'Validé',
        AppColors.success,
        AppColors.successBackground,
      ),
      DriverDocumentStatus.expiringSoon => (
        'À renouveler',
        AppColors.warning,
        AppColors.warningBackground,
      ),
      DriverDocumentStatus.expired => (
        'Expiré',
        AppColors.danger,
        AppColors.dangerBackground,
      ),
      DriverDocumentStatus.missing => (
        'À envoyer',
        AppColors.danger,
        AppColors.dangerBackground,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: document.needsAction
                  ? background
                  : AppColors.border.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon(document.kind),
              size: 18,
              color: document.needsAction ? color : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  document.detail,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(DriverDocumentKind kind) => switch (kind) {
    DriverDocumentKind.professionalCard => Icons.badge_outlined,
    DriverDocumentKind.parkingPermit => Icons.description_outlined,
    DriverDocumentKind.drivingLicence => Icons.badge_outlined,
    DriverDocumentKind.vehicle => Icons.directions_car_outlined,
    DriverDocumentKind.taximeter => Icons.speed,
    DriverDocumentKind.paymentTerminal => Icons.credit_card,
  };
}
