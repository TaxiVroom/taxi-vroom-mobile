import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// What the round on the right of a document card shows.
enum DocumentCardAction {
  // "+": the document can be sent.
  add,
  // A spinner: being sent.
  sending,
  // A check: sent, or in order.
  done,
  // "↻": the sending failed, it can be sent again.
  retry,
}

/// The small coloured label under the document's name, e.g. "AJOUTER".
class DocumentCardBadge {
  const DocumentCardBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

/// A driver's document as a card: icon, name, a line of detail, its label
/// and the round on the right. The same at the registration and in "Vos
/// documents" (spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md).
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    required this.name,
    required this.detail,
    required this.badge,
    required this.action,
    required this.actionColor,
    required this.actionBackground,
    this.onTap,
    this.borderColor,
    super.key,
  });

  final String name;

  // E.g. "Recto + Verso requis", "Valable jusqu'au 20 nov. 2026 inclus".
  final String detail;

  final DocumentCardBadge badge;
  final DocumentCardAction action;
  final Color actionColor;
  final Color actionBackground;

  // Null: the card does not react to a touch.
  final VoidCallback? onTap;

  // Null: the theme's border.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor ?? colorScheme.border,
            width: 1.5.w,
          ),
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
            _buildIconBox(colorScheme),
            SizedBox(width: 16.w),
            Expanded(child: _buildInfo(colorScheme)),
            SizedBox(width: 12.w),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(ColorScheme colorScheme) {
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

  Widget _buildInfo(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: colorScheme.cardForeground,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          detail,
          style: TextStyle(fontSize: 13.sp, color: colorScheme.mutedForeground),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: badge.background,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            badge.label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: badge.foreground,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAction() {
    if (action == DocumentCardAction.sending) {
      return SizedBox(
        width: 36.w,
        height: 36.w,
        child: CircularProgressIndicator(strokeWidth: 2.5.w),
      );
    }
    final icon = switch (action) {
      DocumentCardAction.add || DocumentCardAction.sending => Icons.add,
      DocumentCardAction.done => Icons.check,
      DocumentCardAction.retry => Icons.refresh,
    };
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: actionBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18.r, color: actionColor),
    );
  }
}
