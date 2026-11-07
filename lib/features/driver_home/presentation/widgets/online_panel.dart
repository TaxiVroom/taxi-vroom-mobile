import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/connection_lost_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 3: waiting for a ride.
class OnlinePanel extends StatelessWidget {
  const OnlinePanel({
    required this.isConnected,
    required this.isSwitching,
    required this.onGoOfflinePressed,
    this.failureMessage,
    super.key,
  });

  // Without connection, passengers no longer see the driver.
  final bool isConnected;
  final bool isSwitching;
  final VoidCallback onGoOfflinePressed;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    return BottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected) ...[
            const ConnectionLostBanner(
              consequence: 'Vous n’êtes plus visible des passagers.',
            ),
            const SizedBox(height: 12),
          ],
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'En attente de course',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                'Lumineux vert',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          if (failureMessage case final message?) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 8),
          SecondaryButton(
            onPressed: isSwitching ? null : onGoOfflinePressed,
            alignment: Alignment.center,
            child: const Text('Passer hors ligne'),
          ),
        ],
      ),
    );
  }
}
