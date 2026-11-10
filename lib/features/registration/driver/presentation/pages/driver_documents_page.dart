import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/document_card.dart';
import 'package:mobile/core/widgets/document_photo_slot.dart';
import 'package:mobile/core/widgets/expiry_date_field.dart';
import 'package:mobile/features/registration/driver/domain/entities/document_signed_urls.dart';
import 'package:mobile/features/registration/driver/domain/entities/document_type.dart';
import 'package:mobile/features/registration/driver/presentation/bloc/driver_registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DriverDocumentsPage extends StatefulWidget {
  const DriverDocumentsPage({super.key});

  @override
  State<DriverDocumentsPage> createState() => _DriverDocumentsPageState();
}

class _DriverDocumentsPageState extends State<DriverDocumentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverRegistrationBloc>().add(
      const DocumentTypesFetchRequested(),
    );
  }

  void _openDocumentCaptureSheet(
    BuildContext context,
    DocumentType documentType,
    DocumentUploadStatus? previousUploadStatus,
    DocumentSignedUrls? signedUrls,
  ) {
    log(
      '[DriverDocumentsPage] Ouverture de la feuille de capture — document="${documentType.name}" statut précédent=$previousUploadStatus',
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<DriverRegistrationBloc>(),
        child: _DocumentCaptureBottomSheet(
          documentType: documentType,
          previousUploadStatus: previousUploadStatus,
          signedUrls: signedUrls,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverRegistrationBloc, RegistrationState>(
      listenWhen: (previous, current) {
        if (current is! DriverRegDocumentsReady) return false;
        final prev = previous is DriverRegDocumentsReady ? previous : null;
        return prev?.signedUrls != current.signedUrls;
      },
      listener: (context, state) {
        if (state is! DriverRegDocumentsReady) return;
        for (final urls in state.signedUrls.values) {
          precacheImage(NetworkImage(urls.frontUrl), context);
          if (urls.backUrl != null) {
            precacheImage(NetworkImage(urls.backUrl!), context);
          }
        }
      },
      child: BlocBuilder<DriverRegistrationBloc, RegistrationState>(
        buildWhen: (_, current) => current is DriverRegDocumentsReady,
        builder: (context, state) {
          if (state is! DriverRegDocumentsReady) return const SizedBox.shrink();
          return _buildPage(context, state);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, DriverRegDocumentsReady state) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        headers: [
          AppBar(
            backgroundColor: colorScheme.background,
            leading: [
              GhostButton(
                density: ButtonDensity.icon,
                onPressed: () => context.read<DriverRegistrationBloc>().add(
                  const DocumentsStepBackRequested(),
                ),
                child: const Icon(Icons.arrow_back),
              ),
            ],
          ),
        ],
        footers: [_buildSubmitButton(context, state)],
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes Documents',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.foreground,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Mettez à jour vos pièces justificatives',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.mutedForeground,
                ),
              ),
              if (state.isNewDocumentAsked) ...[
                SizedBox(height: 16.h),
                const Alert(
                  leading: Icon(Icons.info_outline),
                  title: Text('Un nouveau document est demandé'),
                  content: Text(
                    'Ajoutez-le, puis envoyez à nouveau votre dossier.',
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              if (state.isLoadingDocumentTypes)
                const Center(child: CircularProgressIndicator())
              else
                for (final (index, documentType)
                    in state.documentTypes.indexed) ...[
                  if (index > 0) SizedBox(height: 12.h),
                  _DocumentCard(
                    documentType: documentType,
                    uploadStatus: state.uploadStatuses[documentType.id],
                    isTappable: state.isDocumentTappable(documentType.id),
                    onTap: () => _openDocumentCaptureSheet(
                      context,
                      documentType,
                      state.uploadStatuses[documentType.id],
                      state.signedUrls[documentType.id],
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    DriverRegDocumentsReady state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSubmitting =
        context.watch<DriverRegistrationBloc>().state
            is DriverRegDocumentsSubmitting;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: colorScheme.background,
        border: Border(top: BorderSide(color: colorScheme.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          onPressed: (state.areAllDocumentsUploaded && !isSubmitting)
              ? () {
                  log(
                    '[DriverDocumentsPage] Bouton "Envoyer mon dossier" appuyé — tous les documents sont uploadés',
                  );
                  context.read<DriverRegistrationBloc>().add(
                    const DriverRegistrationDocumentsContinued(),
                  );
                }
              : null,
          alignment: Alignment.center,
          trailing: isSubmitting
              ? const AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(onSurface: true),
                )
              : null,
          child: const Text('Envoyer mon dossier'),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.documentType,
    required this.uploadStatus,
    required this.isTappable,
    required this.onTap,
  });

  final DocumentType documentType;
  final DocumentUploadStatus? uploadStatus;
  final bool isTappable;
  final VoidCallback onTap;

  // The shared card, also used by "Vos documents" of the driver's home.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary.withValues(alpha: 0.12);
    final failed = colorScheme.destructive.withValues(alpha: 0.12);
    final (
      badge,
      action,
      actionColor,
      actionBackground,
    ) = switch (uploadStatus) {
      DocumentUploadStatus.succeeded => (
        const DocumentCardBadge(
          label: 'ENVOYÉ',
          background: AppColors.successBackground,
          foreground: AppColors.success,
        ),
        DocumentCardAction.done,
        AppColors.success,
        AppColors.successBackground,
      ),
      DocumentUploadStatus.failed => (
        DocumentCardBadge(
          label: 'ÉCHEC',
          background: failed,
          foreground: colorScheme.destructive,
        ),
        DocumentCardAction.retry,
        colorScheme.destructive,
        failed,
      ),
      DocumentUploadStatus.uploading => (
        DocumentCardBadge(
          label: 'ENVOI...',
          background: primary,
          foreground: colorScheme.primary,
        ),
        DocumentCardAction.sending,
        colorScheme.primary,
        primary,
      ),
      null => (
        DocumentCardBadge(
          label: 'AJOUTER',
          background: primary,
          foreground: colorScheme.primary,
        ),
        DocumentCardAction.add,
        colorScheme.primary,
        primary,
      ),
    };
    return DocumentCard(
      name: documentType.name,
      detail: documentType.backRequired
          ? 'Recto + Verso requis'
          : 'Recto uniquement',
      badge: badge,
      action: action,
      actionColor: actionColor,
      actionBackground: actionBackground,
      onTap: isTappable ? onTap : null,
      borderColor: switch (uploadStatus) {
        DocumentUploadStatus.failed => colorScheme.destructive,
        DocumentUploadStatus.succeeded => Colors.transparent,
        _ => null,
      },
    );
  }
}

class _DocumentCaptureBottomSheet extends StatefulWidget {
  const _DocumentCaptureBottomSheet({
    required this.documentType,
    required this.previousUploadStatus,
    required this.signedUrls,
  });

  final DocumentType documentType;
  final DocumentUploadStatus? previousUploadStatus;
  final DocumentSignedUrls? signedUrls;

  @override
  State<_DocumentCaptureBottomSheet> createState() =>
      _DocumentCaptureBottomSheetState();
}

class _DocumentCaptureBottomSheetState
    extends State<_DocumentCaptureBottomSheet> {
  CroppedFile? _capturedFrontPhoto;
  CroppedFile? _capturedBackPhoto;
  DateTime? _expiresAt;

  final _imagePicker = ImagePicker();
  final _imageCropper = ImageCropper();

  bool get _isReplacement =>
      widget.previousUploadStatus == DocumentUploadStatus.succeeded;
  bool get _hasFrontPhoto => _capturedFrontPhoto != null;
  bool get _hasBackPhoto => _capturedBackPhoto != null;

  bool _canFinalizeUpload(DriverRegDocumentsReady state) =>
      state.canFinalizeUpload(
        documentTypeId: widget.documentType.id,
        hasFront: _hasFrontPhoto,
        hasBack: _hasBackPhoto,
        hasExpiry: _expiresAt != null,
      );

  @override
  void initState() {
    super.initState();
    // The date already sent, typed again only to change it.
    final state = context.read<DriverRegistrationBloc>().state;
    if (state is DriverRegDocumentsReady) {
      _expiresAt = state.lastValidDays[widget.documentType.id];
    }
    if (_isReplacement && widget.signedUrls == null) {
      context.read<DriverRegistrationBloc>().add(
        DocumentSignedUrlsRequested(
          documentTypeId: widget.documentType.id,
          backRequired: widget.documentType.backRequired,
        ),
      );
    }
  }

  Future<void> _onFrontPhotoSlotTapped() async {
    log(
      '[DocumentCaptureBottomSheet] Slot recto appuyé — document="${widget.documentType.name}"',
    );
    final photo = await _pickAndCropPhoto(
      hint: 'Recto — ${widget.documentType.name}',
    );
    if (photo != null) {
      log(
        '[DocumentCaptureBottomSheet] Photo recto capturée — chemin=${photo.path}',
      );
      setState(() => _capturedFrontPhoto = photo);
    } else {
      log(
        '[DocumentCaptureBottomSheet] Capture recto annulée par l\'utilisateur',
      );
    }
  }

  Future<void> _onBackPhotoSlotTapped() async {
    log(
      '[DocumentCaptureBottomSheet] Slot verso appuyé — document="${widget.documentType.name}"',
    );
    final photo = await _pickAndCropPhoto(
      hint: 'Verso — ${widget.documentType.name}',
    );
    if (photo != null) {
      log(
        '[DocumentCaptureBottomSheet] Photo verso capturée — chemin=${photo.path}',
      );
      setState(() => _capturedBackPhoto = photo);
    } else {
      log(
        '[DocumentCaptureBottomSheet] Capture verso annulée par l\'utilisateur',
      );
    }
  }

  Future<CroppedFile?> _pickAndCropPhoto({required String hint}) async {
    log(
      '[DocumentCaptureBottomSheet] Ouverture de la galerie — indice="$hint"',
    );
    final pickedPhoto = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedPhoto == null) {
      log(
        '[DocumentCaptureBottomSheet] Aucune photo sélectionnée dans la galerie',
      );
      return null;
    }

    log(
      '[DocumentCaptureBottomSheet] Photo sélectionnée, ouverture du recadrage — chemin=${pickedPhoto.path}',
    );
    final croppedPhoto = await _imageCropper.cropImage(
      sourcePath: pickedPhoto.path,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: hint, lockAspectRatio: false),
        IOSUiSettings(title: hint),
      ],
    );

    if (croppedPhoto == null) {
      log('[DocumentCaptureBottomSheet] Recadrage annulé par l\'utilisateur');
    } else {
      log(
        '[DocumentCaptureBottomSheet] Recadrage terminé — chemin=${croppedPhoto.path}',
      );
    }
    return croppedPhoto;
  }

  void _onFinalizeUploadPressed(BuildContext context) {
    log(
      '[DocumentCaptureBottomSheet] "Finaliser l\'envoi" appuyé — documentTypeId=${widget.documentType.id} verso=${_capturedBackPhoto != null}',
    );
    context.read<DriverRegistrationBloc>().add(
      DocumentUploadRequested(
        documentTypeId: widget.documentType.id,
        frontFilePath: _capturedFrontPhoto?.path,
        backFilePath: _capturedBackPhoto?.path,
        expiresAt: _expiresAt,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for signed URLs fetched by the BLoC after initState dispatch.
    return BlocBuilder<DriverRegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) {
        if (current is! DriverRegDocumentsReady) return false;
        final prev = previous is DriverRegDocumentsReady ? previous : null;
        return prev?.signedUrls[widget.documentType.id] !=
            current.signedUrls[widget.documentType.id];
      },
      builder: (context, state) {
        final urls = state is DriverRegDocumentsReady
            ? state.signedUrls[widget.documentType.id]
            : widget.signedUrls;
        return _buildSheet(context, urls);
      },
    );
  }

  Widget _buildSheet(BuildContext context, DocumentSignedUrls? urls) {
    final colorScheme = Theme.of(context).colorScheme;
    final blocState = context.watch<DriverRegistrationBloc>().state;
    final docState = blocState is DriverRegDocumentsReady ? blocState : null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSheetHandle(colorScheme),
          SizedBox(height: 16.h),
          _buildSheetHeader(context, colorScheme),
          SizedBox(height: 8.h),
          _buildPhotoQualityHint(colorScheme),
          if (_isReplacement) ...[
            SizedBox(height: 12.h),
            _buildReplacePhotoHint(),
          ] else if (widget.previousUploadStatus ==
              DocumentUploadStatus.failed) ...[
            SizedBox(height: 12.h),
            _buildUploadFailedWarning(colorScheme),
          ],
          SizedBox(height: 24.h),
          _buildPhotoSlots(urls),
          if (widget.documentType.expires) ...[
            SizedBox(height: 20.h),
            ExpiryDateField(
              value: _expiresAt,
              onChanged: (date) => setState(() => _expiresAt = date),
            ),
          ],
          SizedBox(height: 32.h),
          _buildFinalizeUploadButton(context, docState),
        ],
      ),
    );
  }

  Widget _buildSheetHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: colorScheme.border,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.documentType.name,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.cardForeground,
          ),
        ),
        GhostButton(
          density: ButtonDensity.icon,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.close,
            size: 20.r,
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoQualityHint(ColorScheme colorScheme) {
    return Text(
      'Assurez-vous que le texte est bien lisible et sans reflets.',
      style: TextStyle(fontSize: 14.sp, color: colorScheme.mutedForeground),
    );
  }

  Widget _buildReplacePhotoHint() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16.r, color: AppColors.success),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Document déjà envoyé. Vous pouvez remplacer vos photos si besoin.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadFailedWarning(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.destructive.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16.r, color: colorScheme.destructive),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "L'envoi a échoué. Vérifiez votre connexion et réessayez.",
              style: TextStyle(fontSize: 13.sp, color: colorScheme.destructive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlots(DocumentSignedUrls? urls) {
    if (widget.documentType.backRequired) {
      return Row(
        children: [
          Expanded(
            child: DocumentPhotoSlot(
              label: 'RECTO',
              capturedFilePath: _capturedFrontPhoto?.path,
              serverThumbnailUrl: urls?.frontUrl,
              onTap: _onFrontPhotoSlotTapped,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: DocumentPhotoSlot(
              label: 'VERSO',
              capturedFilePath: _capturedBackPhoto?.path,
              serverThumbnailUrl: urls?.backUrl,
              onTap: _onBackPhotoSlotTapped,
            ),
          ),
        ],
      );
    }

    return DocumentPhotoSlot(
      label: 'RECTO',
      capturedFilePath: _capturedFrontPhoto?.path,
      serverThumbnailUrl: urls?.frontUrl,
      onTap: _onFrontPhotoSlotTapped,
    );
  }

  Widget _buildFinalizeUploadButton(
    BuildContext context,
    DriverRegDocumentsReady? state,
  ) {
    final canFinalize = state != null && _canFinalizeUpload(state);
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: canFinalize ? () => _onFinalizeUploadPressed(context) : null,
        alignment: Alignment.center,
        child: Text(_isReplacement ? 'Mettre à jour' : "Finaliser l'envoi"),
      ),
    );
  }
}
