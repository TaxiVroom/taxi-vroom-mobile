import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/rating_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/presentation/bloc/driver_activity_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/go_button.dart';
import 'package:mobile/features/driver_home/presentation/widgets/status_dot.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 2: one big button to start working, the driver's figures
/// and their next booking.
class OfflinePanel extends StatelessWidget {
  const OfflinePanel({
    required this.activityState,
    required this.nextBooking,
    required this.isSwitching,
    required this.onGoOnlinePressed,
    this.failureMessage,
    super.key,
  });

  // The three cards: a small loader, the figures, or "–" when the API
  // failed.
  final DriverActivityState activityState;
  final DriverBooking? nextBooking;
  final bool isSwitching;
  final VoidCallback onGoOnlinePressed;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    final booking = nextBooking;
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
          GoButton(
            label: 'Passer en ligne',
            icon: Icons.power_settings_new,
            isLoading: isSwitching,
            onPressed: onGoOnlinePressed,
          ),
          if (failureMessage case final message?) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 14),
          _buildStats(),
          if (booking != null) ...[
            const SizedBox(height: 14),
            _buildNextBooking(booking),
          ],
        ],
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

  Widget _buildNextBooking(DriverBooking booking) {
    final pickup = formatPickupTimeInSentence(
      booking.scheduledPickup,
      now: DateTime.now(),
    );
    final luggage = booking.luggageCount > 1
        ? '${booking.luggageCount} bagages'
        : '${booking.luggageCount} bagage';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_outlined,
                size: 16,
                color: AppColors.freeTaxi,
              ),
              const SizedBox(width: 6),
              Text(
                'Réservation acceptée, $pickup',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.freeTaxi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${booking.pickupName} → ${booking.destinationName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            '${formatDistanceKm(booking.distanceKm)}, '
            'client : ${booking.customerFirstName}, $luggage',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
