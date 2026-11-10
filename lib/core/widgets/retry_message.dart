import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Centered error message with a "Réessayer" button, and optionally a
/// second way out, e.g. "Ouvrir les réglages".
class RetryMessage extends StatelessWidget {
  const RetryMessage({
    required this.message,
    required this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
            if (secondaryLabel case final label?) ...[
              const SizedBox(height: 8),
              SecondaryButton(onPressed: onSecondary, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
