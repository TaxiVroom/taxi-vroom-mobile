import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/map_pill.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_for_arrival_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/arrival_pickup_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_history_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/taxi_choice_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/pickup_time_chip.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/route_map.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/taxi_offer_tile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 5: the route on the map, the kinds of taxi with their
/// estimated price, and the order button.
class TaxiChoicePage extends StatelessWidget {
  const TaxiChoicePage({
    required this.origin,
    required this.destination,
    required this.loadTaxiChoiceUseCase,
    required this.requestRideUseCase,
    required this.bookRideUseCase,
    required this.getPickupForArrivalUseCase,
    this.scheduledPickup,
    super.key,
  });

  final Coordinates origin;
  final Place destination;
  final LoadTaxiChoiceUseCase loadTaxiChoiceUseCase;
  final RequestRideUseCase requestRideUseCase;
  final BookRideUseCase bookRideUseCase;
  final GetPickupForArrivalUseCase getPickupForArrivalUseCase;

  // Null means "as soon as possible".
  final DateTime? scheduledPickup;

  // Room kept for the bottom panel when framing the route on the map.
  static const _panelHeight = 440.0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TaxiChoiceBloc(
            origin: origin,
            destination: destination,
            loadTaxiChoiceUseCase: loadTaxiChoiceUseCase,
            requestRideUseCase: requestRideUseCase,
            bookRideUseCase: bookRideUseCase,
          )..add(const TaxiChoiceStarted()),
        ),
        BlocProvider(
          create: (_) => ArrivalPickupBloc(
            origin: origin,
            destination: destination.coordinates,
            getPickupForArrivalUseCase: getPickupForArrivalUseCase,
          ),
        ),
      ],
      child: BlocListener<TaxiChoiceBloc, TaxiChoiceState>(
        listenWhen: (_, current) =>
            current is TaxiChoiceReady &&
            (current.orderedRideId != null || current.bookedRideId != null),
        listener: (context, state) =>
            _onOrderConfirmed(context, state as TaxiChoiceReady),
        child: PopScope(
          canPop: false,
          // The hardware back goes through the flow bloc, not the Navigator.
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBackPressed(context);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            child: BlocBuilder<TaxiChoiceBloc, TaxiChoiceState>(
              builder: (context, state) => Stack(
                children: [
                  Positioned.fill(child: _buildContent(context, state)),
                  Positioned(
                    top: 0,
                    left: 16,
                    child: SafeArea(
                      child: SecondaryButton(
                        density: ButtonDensity.icon,
                        onPressed: () => _onBackPressed(context),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TaxiChoiceState state) {
    return switch (state) {
      TaxiChoiceLoading() => const Center(child: CircularProgressIndicator()),
      TaxiChoiceFailure(:final message) => RetryMessage(
        message: message,
        onRetry: () =>
            context.read<TaxiChoiceBloc>().add(const TaxiChoiceStarted()),
      ),
      TaxiChoiceReady(:final choice, :final selectedOfferId) => Stack(
        children: [
          Positioned.fill(
            child: RouteMap(
              route: choice.route,
              bottomPadding: _panelHeight,
            ),
          ),
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(child: _buildArrival(choice, selectedOfferId)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomPanel(child: _buildPanel(context, state)),
          ),
        ],
      ),
    };
  }

  Widget _buildArrival(TaxiChoice choice, String? selectedOfferId) {
    final selectedOffer = choice.offerById(selectedOfferId);
    if (selectedOffer == null) return const SizedBox.shrink();
    final arrival = choice.estimatedArrival(
      offer: selectedOffer,
      now: DateTime.now(),
      scheduledPickup: scheduledPickup,
    );
    return MapPill(text: 'Arrivée vers ${formatClockTime(arrival)}');
  }

  Widget _buildPanel(BuildContext context, TaxiChoiceReady state) {
    final choice = state.choice;
    final selectedOfferId = state.selectedOfferId;
    final orderFailureMessage = state.orderFailureMessage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Votre taxi',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(
              '${formatDistanceKm(choice.route.distanceKm)}, '
              '${choice.route.durationMinutes} min',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final offer in choice.offers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TaxiOfferTile(
              offer: offer,
              isSelected: offer.id == selectedOfferId,
              onPressed: () => context.read<TaxiChoiceBloc>().add(
                TaxiOfferSelected(offerId: offer.id),
              ),
            ),
          ),
        _buildOptions(),
        const SizedBox(height: 8),
        const Text(
          "Prix final au compteur, tarif réglementé. L'estimation inclut "
          "l'approche du taxi.",
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        if (orderFailureMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            orderFailureMessage,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
        const SizedBox(height: 12),
        PrimaryButton(
          onPressed: selectedOfferId == null || state.isOrdering
              ? null
              : () => _onOrderPressed(context),
          alignment: Alignment.center,
          trailing: state.isOrdering
              ? const AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(onSurface: true),
                )
              : null,
          child: Text(
            scheduledPickup == null ? 'Commander le taxi' : 'Réserver le taxi',
          ),
        ),
      ],
    );
  }

  void _onOrderPressed(BuildContext context) {
    final pickup = scheduledPickup;
    context.read<TaxiChoiceBloc>().add(
      pickup == null
          ? const TaxiRideOrdered()
          : TaxiRideBooked(scheduledPickup: pickup),
    );
  }

  // Ordered now: follow the ride. Booked: back home, it waits in
  // "Mes courses".
  void _onOrderConfirmed(BuildContext context, TaxiChoiceReady state) {
    final flowBloc = context.read<PassengerFlowBloc>();
    final orderedRideId = state.orderedRideId;
    final pickup = scheduledPickup;
    if (orderedRideId != null) {
      flowBloc.add(PassengerRideOrdered(rideId: orderedRideId));
      return;
    }
    if (pickup == null) return;
    showMessageToast(
      context,
      title: 'Taxi réservé',
      message:
          '${formatPickupTime(pickup, now: DateTime.now())}. '
          'Retrouvez-le dans Mes courses.',
    );
    context.read<RideHistoryBloc>().add(const RideHistoryRequested());
    flowBloc.add(const PassengerRideBooked());
  }

  // The passenger count is not built yet.
  Widget _buildOptions() {
    return Row(
      children: [
        const PickupTimeChip(canChooseArrival: true),
        const SizedBox(width: 8),
        OutlineButton(
          onPressed: () {},
          leading: const Icon(Icons.person_outline, size: 16),
          child: const Text('1 passager'),
        ),
      ],
    );
  }

  void _onBackPressed(BuildContext context) {
    context.read<PassengerFlowBloc>().add(const PassengerFlowBackPressed());
  }
}
