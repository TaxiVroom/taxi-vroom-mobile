import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/rating_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_activity_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/status_dot.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 2: one big button to start working and the driver's
/// figures. No booking here: they are in their tab only (user's request,
/// 2026-11-11).
class OfflinePanel extends StatelessWidget {
  const OfflinePanel({
    required this.activityState,
    required this.isSwitching,
    required this.onGoOnlinePressed,
    this.failureMessage,
    super.key,
  });

  // The three cards: a small loader, the figures, or "–" when the API
  // failed.
  final DriverActivityState activityState;
  final bool isSwitching;
  final VoidCallback onGoOnlinePressed;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    return BottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusDot(label: 'Hors ligne', color: AppColors.muted),
              Text(
                'Lumineux éteint',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildGoOnlineButton(context),
          if (failureMessage case final message?) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 14),
          _buildStats(),
        ],
      ),
    );
  }

  // The same button as "Continuer" after the phone number (phone_number_page):
  // shadcn's primary button at its normal size, the loader after the text;
  // in green, with the power sign, to start working. shadcn_flutter 0.0.51's
  // withBackgroundColor only colors the states it is given: hovered and
  // focused (right after a tap) fell back to the theme's blue. Disabled,
  // while going online, is the grey shadcn gives "Continuer" disabled.
  Widget _buildGoOnlineButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Button(
        style: const ButtonStyle.primary().withBackgroundColor(
          color: AppColors.freeTaxi,
          hoverColor: AppColors.freeTaxi,
          focusColor: AppColors.freeTaxi,
          disabledColor: Theme.of(context).colorScheme.mutedForeground,
        ),
        onPressed: isSwitching ? null : onGoOnlinePressed,
        alignment: Alignment.center,
        leading: const Icon(Icons.power_settings_new),
        trailing: isSwitching
            ? const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(onSurface: true),
              )
            : null,
        child: const Text('Passer en ligne'),
      ),
    );
  }

  // A null value shows "–": the API failed, no rating yet, or under 10
  // requests.
  Widget _buildStats() {
    final isLoading = activityState is DriverActivityLoading;
    final activity = switch (activityState) {
      DriverActivityReady(:final activity) => activity,
      _ => null,
    };
    final rating = activity?.averageRating;
    final acceptance = activity?.acceptanceRatePercent;
    return Row(
      children: [
        _buildStat(
          activity == null ? null : '${activity.weekRideCount}',
          'courses, semaine',
          isLoading: isLoading,
        ),
        const SizedBox(width: 8),
        _buildStat(
          rating == null ? null : formatRating(rating),
          'note moyenne',
          isLoading: isLoading,
        ),
        const SizedBox(width: 8),
        _buildStat(
          acceptance == null ? null : '$acceptance %',
          'acceptation',
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildStat(String? value, String label, {required bool isLoading}) {
    const valueStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The spinner takes the line of the value: the card keeps its
            // height.
            if (isLoading)
              const SizedBox(
                height: 24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(size: 16, strokeWidth: 2),
                ),
              )
            else
              Text(value ?? '–', style: valueStyle),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
