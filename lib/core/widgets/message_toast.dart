import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Short message over the screen, same style as the navigators' error toasts.
void showMessageToast(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showToast(
    context: context,
    builder: (_, overlay) => SurfaceCard(
      child: Basic(
        title: Text(title),
        subtitle: Text(message),
        trailing: PrimaryButton(
          size: ButtonSize.small,
          onPressed: overlay.close,
          child: const Text('OK'),
        ),
      ),
    ),
  );
}
