import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/paged_list_view.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_history_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 10: booked rides first, then the past ones. Each list loads
/// page by page while the passenger scrolls (spec
/// taxi-vroom-api/docs/specs/mes-courses-par-pages.md).
class RideHistoryTab extends StatelessWidget {
  const RideHistoryTab({super.key});

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
            BlocBuilder<RideHistoryBloc, RideHistoryState>(
              buildWhen: (previous, current) => previous.shown != current.shown,
              builder: (context, state) => Row(
                children: [
                  Expanded(
                    child: ChoiceButton(
                      label: 'À venir',
                      isSelected: state.shown == RideHistoryList.upcoming,
                      onPressed: () => context.read<RideHistoryBloc>().add(
                        const RideHistoryListSelected(RideHistoryList.upcoming),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceButton(
                      label: 'Passées',
                      isSelected: state.shown == RideHistoryList.past,
                      onPressed: () => context.read<RideHistoryBloc>().add(
                        const RideHistoryListSelected(RideHistoryList.past),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<RideHistoryBloc, RideHistoryState>(
                // A failed cancellation or page: the same message at the
                // bottom as elsewhere.
                listenWhen: (_, current) =>
                    current is RideHistoryReady &&
                    (current.failureMessage != null ||
                        current.nextPageFailureMessage != null),
                listener: (context, state) {
                  final ready = state as RideHistoryReady;
                  final cancelMessage = ready.failureMessage;
                  showMessageToast(
                    context,
                    title: cancelMessage == null
                        ? 'Chargement impossible'
                        : 'Annulation impossible',
                    message: cancelMessage ?? ready.nextPageFailureMessage!,
                  );
                },
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
                  RideHistoryReady() => _buildHistory(context, state),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A list not opened yet shows the loader until its first page comes.
  Widget _buildHistory(BuildContext context, RideHistoryReady state) {
    switch (state.shown) {
      case RideHistoryList.upcoming:
        final upcoming = state.upcoming;
        if (upcoming == null) return _buildLoader();
        if (upcoming.items.isEmpty) {
          return _buildEmpty('Aucune course réservée.');
        }
        return _buildPages(
          context,
          state,
          itemCount: upcoming.items.length,
          itemBuilder: (context, index) {
            final ride = upcoming.items[index];
            return _buildBookedRide(
              context,
              ride,
              isCancelling: state.cancellingId == ride.id,
              canCancel: state.cancellingId == null,
            );
          },
        );
      case RideHistoryList.past:
        final past = state.past;
        if (past == null) return _buildLoader();
        if (past.items.isEmpty) {
          return _buildEmpty('Aucune course pour l’instant.');
        }
        return _buildPages(
          context,
          state,
          itemCount: past.items.length,
          itemBuilder: (context, index) => _buildPastRide(past.items[index]),
        );
    }
  }

  Widget _buildLoader() => const Center(child: CircularProgressIndicator());

  Widget _buildPages(
    BuildContext context,
    RideHistoryReady state, {
    required int itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,
  }) => PagedListView(
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    isLoadingNextPage: state.isLoadingNextPage,
    onNextPage: () => context.read<RideHistoryBloc>().add(
      const RideHistoryNextPageRequested(),
    ),
  );

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
    BuildContext context,
    BookedRide ride, {
    required bool isCancelling,
    required bool canCancel,
  }) {
    final pickup = formatPickupTime(ride.scheduledPickup, now: DateTime.now());
    final estimate = formatEuroRange(ride.minPriceCents, ride.maxPriceCents);
    return _buildCard(
      Column(
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

  // Both addresses are written in full, wrapped on as many lines as needed.
  Widget _buildPastRide(PastRide ride) {
    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatShortDateTime(ride.startedAt),
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              Text(
                formatEuro(ride.totalCents),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Destination : ${ride.destinationName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Départ : ${ride.originName}',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
