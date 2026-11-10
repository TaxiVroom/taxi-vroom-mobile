import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Picks a photo of a document in the gallery, then crops it. Null when the
/// driver gives up.
Future<String?> pickDocumentPhoto({required String hint}) async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked == null) return null;
  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    uiSettings: [
      AndroidUiSettings(toolbarTitle: hint, lockAspectRatio: false),
      IOSUiSettings(title: hint),
    ],
  );
  return cropped?.path;
}

/// A side of a document's photo: the one just taken, the one already sent,
/// or an empty slot. Shared by the registration and the renewal of a
/// document (spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md).
class DocumentPhotoSlot extends StatelessWidget {
  const DocumentPhotoSlot({
    super.key,
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
        Icon(
          Icons.camera_alt_outlined,
          size: 28.r,
          color: colorScheme.mutedForeground,
        ),
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
