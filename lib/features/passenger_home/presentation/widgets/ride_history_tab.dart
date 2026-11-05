import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_history_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 10: booked rides first, then the past ones.
class RideHistoryTab extends StatefulWidget {
  const RideHistoryTab({super.key});

  @override
  State<RideHistoryTab> createState() => _RideHistoryTabState();
}

class _RideHistoryTabState extends State<RideHistoryTab> {
  bool _showsUpcoming = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mes courses',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceButton(
                    label: 'À venir',
                    isSelected: _showsUpcoming,
                    onPressed: () => setState(() => _showsUpcoming = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceButton(
                    label: 'Passées',
                    isSelected: !_showsUpcoming,
                    onPressed: () => setState(() => _showsUpcoming = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<RideHistoryBloc, RideHistoryState>(
                // A failed cancellation: the same message at the bottom as
                // elsewhere.
                listenWhen: (_, current) =>
                    current is RideHistoryReady &&
                    current.failureMessage != null,
                listener: (context, state) => showMessageToast(
                  context,
                  title: 'Annulation impossible',
                  message: (state as RideHistoryReady).failureMessage!,
                ),
                builder: (context, state) => switch (state) {
                  RideHistoryLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  RideHistoryFailure(:final message) => RetryMessage(
                    message: message,
                    onRetry: () => context.read<RideHistoryBloc>().add(
                      const RideHistoryRequested(),
                    ),
                  ),
                  RideHistoryReady() => _buildHistory(state),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(RideHistoryReady state) {
    final history = state.history;
    if (_showsUpcoming) {
      return ListView(
        children: [
          if (history.upcoming.isEmpty)
            _buildEmpty('Aucune course réservée.')
          else
            for (final ride in history.upcoming)
              _buildBookedRide(
                ride,
                isCancelling: state.cancellingId == ride.id,
                canCancel: state.cancellingId == null,
              ),
        ],
      );
    }
    return history.past.isEmpty
        ? _buildEmpty('Aucune course pour l’instant.')
        : ListView(
            children: [
              for (final ride in history.past) _buildPastRide(ride),
            ],
          );
  }

  Widget _buildEmpty(String message) {
    return Text(message, style: const TextStyle(color: AppColors.muted));
  }

  // A driver may commit until 30 min before; then the closest free one is
  // asked.
  String _driverLine(String? driverFirstName) => driverFirstName == null
      ? 'En attente d’un chauffeur. Sinon, le taxi libre le plus proche est '
            'appelé 30 min avant.'
      : '$driverFirstName viendra vous chercher. Vous serez prévenu à son '
            'départ.';

  Widget _buildBookedRide(
    BookedRide ride, {
    required bool isCancelling,
    required bool canCancel,
  }) {
    final pickup = formatPickupTime(ride.scheduledPickup, now: DateTime.now());
    final estimate = formatEuroRange(ride.minPriceCents, ride.maxPriceCents);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                pickup,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.freeTaxi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ride.destinationName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'Depuis ${ride.originName}, ${ride.offerName}, $estimate estimé',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            _driverLine(ride.driverFirstName),
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Changing a booking is not built yet.
              Expanded(
                child: OutlineButton(
                  onPressed: () {},
                  alignment: Alignment.center,
                  child: const Text('Modifier'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DestructiveButton(
                  onPressed: canCancel
                      ? () => context.read<RideHistoryBloc>().add(
                          BookingCancelRequested(bookingId: ride.id),
                        )
                      : null,
                  alignment: Alignment.center,
                  trailing: isCancelling
                      ? const AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator(onSurface: true),
                        )
                      : null,
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Downloading the ride receipt is not built yet.
  Widget _buildPastRide(PastRide ride) {
    return PlaceListTile(
      icon: Icons.local_taxi_outlined,
      title: '${ride.originName} → ${ride.destinationName}',
      subtitle: formatShortDateTime(ride.startedAt),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatEuro(ride.totalCents),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          GhostButton(
            density: ButtonDensity.icon,
            onPressed: () {},
            child: const Icon(Icons.download_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}
