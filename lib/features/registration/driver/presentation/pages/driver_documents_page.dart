import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/app_colors.dart';
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
    context
        .read<DriverRegistrationBloc>()
        .add(const DocumentTypesFetchRequested());
  }

  void _openDocumentCaptureSheet(
    BuildContext context,
    DocumentType documentType,
    DocumentUploadStatus? previousUploadStatus,
    DocumentSignedUrls? signedUrls,
  ) {
    log('[DriverDocumentsPage] Ouverture de la feuille de capture — document="${documentType.name}" statut précédent=$previousUploadStatus');
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
                onPressed: () => context
                    .read<DriverRegistrationBloc>()
                    .add(const DocumentsStepBackRequested()),
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
    final isSubmitting = context.watch<DriverRegistrationBloc>().state
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
                  log('[DriverDocumentsPage] Bouton "Envoyer mon dossier" appuyé — tous les documents sont uploadés');
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isTappable ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor(colorScheme), width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: colorScheme.foreground.withValues(alpha: 0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildDocumentIconBox(colorScheme),
            SizedBox(width: 16.w),
            Expanded(child: _buildDocumentInfo(colorScheme)),
            SizedBox(width: 12.w),
            _buildUploadStatusWidget(colorScheme),
          ],
        ),
      ),
    );
  }

  Color _borderColor(ColorScheme colorScheme) {
    if (uploadStatus == DocumentUploadStatus.failed) return colorScheme.destructive;
    if (uploadStatus == DocumentUploadStatus.succeeded) return Colors.transparent;
    return colorScheme.border;
  }

  Widget _buildDocumentIconBox(ColorScheme colorScheme) {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        color: colorScheme.muted,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text('🪪', style: TextStyle(fontSize: 20.sp)),
    );
  }

  Widget _buildDocumentInfo(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          documentType.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: colorScheme.cardForeground,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          documentType.backRequired
              ? 'Recto + Verso requis'
              : 'Recto uniquement',
          style: TextStyle(fontSize: 13.sp, color: colorScheme.mutedForeground),
        ),
        SizedBox(height: 6.h),
        _buildUploadStatusBadge(colorScheme),
      ],
    );
  }

  Widget _buildUploadStatusBadge(ColorScheme colorScheme) {
    final (label, backgroundColor, textColor) = switch (uploadStatus) {
      DocumentUploadStatus.succeeded => (
          'ENVOYÉ',
          AppColors.successBackground,
          AppColors.success,
        ),
      DocumentUploadStatus.failed => (
          'ÉCHEC',
          colorScheme.destructive.withValues(alpha: 0.12),
          colorScheme.destructive,
        ),
      DocumentUploadStatus.uploading => (
          'ENVOI...',
          colorScheme.primary.withValues(alpha: 0.12),
          colorScheme.primary,
        ),
      null => (
          'AJOUTER',
          colorScheme.primary.withValues(alpha: 0.12),
          colorScheme.primary,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildUploadStatusWidget(ColorScheme colorScheme) {
    if (uploadStatus == DocumentUploadStatus.uploading) {
      return SizedBox(
        width: 36.w,
        height: 36.w,
        child: CircularProgressIndicator(strokeWidth: 2.5.w),
      );
    }

    final (backgroundColor, iconColor, icon) = switch (uploadStatus) {
      DocumentUploadStatus.succeeded => (
          AppColors.successBackground,
          AppColors.success,
          Icons.check,
        ),
      DocumentUploadStatus.failed => (
          colorScheme.destructive.withValues(alpha: 0.12),
          colorScheme.destructive,
          Icons.refresh,
        ),
      _ => (
          colorScheme.primary.withValues(alpha: 0.12),
          colorScheme.primary,
          Icons.add,
        ),
    };

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 18.r, color: iconColor),
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
      );

  @override
  void initState() {
    super.initState();
    if (_isReplacement && widget.signedUrls == null) {
      context.read<DriverRegistrationBloc>().add(DocumentSignedUrlsRequested(
            documentTypeId: widget.documentType.id,
            backRequired: widget.documentType.backRequired,
          ));
    }
  }

  Future<void> _onFrontPhotoSlotTapped() async {
    log('[DocumentCaptureBottomSheet] Slot recto appuyé — document="${widget.documentType.name}"');
    final photo = await _pickAndCropPhoto(
      hint: 'Recto — ${widget.documentType.name}',
    );
    if (photo != null) {
      log('[DocumentCaptureBottomSheet] Photo recto capturée — chemin=${photo.path}');
      setState(() => _capturedFrontPhoto = photo);
    } else {
      log('[DocumentCaptureBottomSheet] Capture recto annulée par l\'utilisateur');
    }
  }

  Future<void> _onBackPhotoSlotTapped() async {
    log('[DocumentCaptureBottomSheet] Slot verso appuyé — document="${widget.documentType.name}"');
    final photo = await _pickAndCropPhoto(
      hint: 'Verso — ${widget.documentType.name}',
    );
    if (photo != null) {
      log('[DocumentCaptureBottomSheet] Photo verso capturée — chemin=${photo.path}');
      setState(() => _capturedBackPhoto = photo);
    } else {
      log('[DocumentCaptureBottomSheet] Capture verso annulée par l\'utilisateur');
    }
  }

  Future<CroppedFile?> _pickAndCropPhoto({required String hint}) async {
    log('[DocumentCaptureBottomSheet] Ouverture de la galerie — indice="$hint"');
    final pickedPhoto =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedPhoto == null) {
      log('[DocumentCaptureBottomSheet] Aucune photo sélectionnée dans la galerie');
      return null;
    }

    log('[DocumentCaptureBottomSheet] Photo sélectionnée, ouverture du recadrage — chemin=${pickedPhoto.path}');
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
      log('[DocumentCaptureBottomSheet] Recadrage terminé — chemin=${croppedPhoto.path}');
    }
    return croppedPhoto;
  }

  void _onFinalizeUploadPressed(BuildContext context) {
    log('[DocumentCaptureBottomSheet] "Finaliser l\'envoi" appuyé — documentTypeId=${widget.documentType.id} verso=${_capturedBackPhoto != null}');
    context.read<DriverRegistrationBloc>().add(DocumentUploadRequested(
          documentTypeId: widget.documentType.id,
          frontFilePath: _capturedFrontPhoto?.path,
          backFilePath: _capturedBackPhoto?.path,
        ));
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
    final docState =
        blocState is DriverRegDocumentsReady ? blocState : null;

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
          ] else if (widget.previousUploadStatus == DocumentUploadStatus.failed) ...[
            SizedBox(height: 12.h),
            _buildUploadFailedWarning(colorScheme),
          ],
          SizedBox(height: 24.h),
          _buildPhotoSlots(urls),
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
          child: Icon(Icons.close, size: 20.r, color: colorScheme.mutedForeground),
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
            child: _PhotoSlot(
              label: 'RECTO',
              capturedFilePath: _capturedFrontPhoto?.path,
              serverThumbnailUrl: urls?.frontUrl,
              onTap: _onFrontPhotoSlotTapped,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _PhotoSlot(
              label: 'VERSO',
              capturedFilePath: _capturedBackPhoto?.path,
              serverThumbnailUrl: urls?.backUrl,
              onTap: _onBackPhotoSlotTapped,
            ),
          ),
        ],
      );
    }

    return _PhotoSlot(
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
        onPressed:
            canFinalize ? () => _onFinalizeUploadPressed(context) : null,
        alignment: Alignment.center,
        child: Text(_isReplacement ? 'Mettre à jour' : "Finaliser l'envoi"),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.label,
    required this.onTap,
    this.capturedFilePath,
    this.serverThumbnailUrl,
  });

  final String label;

  // Local file path of a photo captured this session — shown in full color.
  final String? capturedFilePath;

  // Remote URL of an existing server photo — shown with a dark overlay + MODIFIER.
  final String? serverThumbnailUrl;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (capturedFilePath != null)
                ..._capturedState(capturedFilePath!)
              else if (serverThumbnailUrl != null)
                ..._serverState(colorScheme, serverThumbnailUrl!)
              else
                ..._emptyState(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // Full-color local image — user can see exactly what they captured.
  List<Widget> _capturedState(String filePath) => [
        Image.file(File(filePath), fit: BoxFit.cover),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: Container(
            padding: EdgeInsets.all(3.r),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 12.r, color: Colors.white),
          ),
        ),
      ];

  // Server image with dark overlay — signals this is the already-submitted version.
  List<Widget> _serverState(ColorScheme colorScheme, String url) => [
        Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  color: colorScheme.muted,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  ),
                ),
          errorBuilder: (_, __, ___) => Container(color: colorScheme.muted),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 28.r, color: Colors.white),
              SizedBox(height: 6.h),
              Text(
                'MODIFIER',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ];

  // Empty slot — no photo yet.
  List<Widget> _emptyState(ColorScheme colorScheme) => [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.muted,
            border: Border.all(color: colorScheme.border, width: 2.w),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 28.r, color: colorScheme.mutedForeground),
            SizedBox(height: 8.h),
            Text(
              'AJOUTER $label',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ];
}
