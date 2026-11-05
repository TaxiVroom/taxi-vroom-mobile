import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Short message over the screen, same style as the navigators' error toasts.
/// With [actionLabel] and [onAction], a second button closes it and acts.
void showMessageToast(
  BuildContext context, {
  required String title,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showToast(
    context: context,
    builder: (_, overlay) => SurfaceCard(
      child: Basic(
        title: Text(title),
        subtitle: Text(message),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (actionLabel != null && onAction != null) ...[
              OutlineButton(
                size: ButtonSize.small,
                onPressed: () {
                  overlay.close();
                  onAction();
                },
                child: Text(actionLabel),
              ),
              const SizedBox(width: 6),
            ],
            PrimaryButton(
              size: ButtonSize.small,
              onPressed: overlay.close,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    ),
  );
}
