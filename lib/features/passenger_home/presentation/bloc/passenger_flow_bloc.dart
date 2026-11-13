import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/pickup_day.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_current_ride_usecase.dart';

part 'passenger_flow_event.dart';
part 'passenger_flow_state.dart';

/// Drives the passenger screens stack (home → destination → taxi choice) and
/// remembers the pickup time and place chosen along the way.
class PassengerFlowBloc extends Bloc<PassengerFlowEvent, PassengerFlowState> {
  PassengerFlowBloc({
    required GetPickupDaysUseCase getPickupDaysUseCase,
    required LoadCurrentRideUseCase loadCurrentRideUseCase,
    required WatchPushedRidesUseCase watchPushedRidesUseCase,
  }) : _getPickupDaysUseCase = getPickupDaysUseCase,
       _loadCurrentRideUseCase = loadCurrentRideUseCase,
       _watchPushedRidesUseCase = watchPushedRidesUseCase,
       super(const PassengerFlowStarting()) {
    on<PassengerFlowStarted>(_onStarted);
    on<PassengerHomeFailed>(_onHomeFailed);
    on<PassengerPushesWatched>(_onPushesWatched);
    on<_PassengerPushedRideOpened>(_onPushedRideOpened);
    on<PassengerDestinationSearchOpened>(_onDestinationSearchOpened);
    on<PassengerDestinationSelected>(_onDestinationSelected);
    on<PassengerSavedPlaceEditOpened>(_onSavedPlaceEditOpened);
    on<PassengerSavedPlaceSaved>(_onSavedPlaceSaved);
    on<PassengerSavedPlaceDeleted>(_onSavedPlaceDeleted);
    on<PassengerRideOrdered>(_onRideOrdered);
    on<PassengerRideEnded>(_onRideEnded);
    on<PassengerRideBooked>(_onRideBooked);
    on<PassengerPickupTimeSheetOpened>(_onPickupTimeSheetOpened);
    on<PassengerPickupTimeChanged>(_onPickupTimeChanged);
    on<PassengerPickupPlaceChanged>(_onPickupPlaceChanged);
    on<PassengerCountChanged>(_onPassengerCountChanged);
    on<PassengerFlowBackPressed>(_onBackPressed);
  }

  final GetPickupDaysUseCase _getPickupDaysUseCase;
  final LoadCurrentRideUseCase _loadCurrentRideUseCase;
  final WatchPushedRidesUseCase _watchPushedRidesUseCase;

  // The notifications are followed once, however often the home reloads.
  bool _watchesPushes = false;

  // Opens the ride to come back to, or leaves the start for the home. If the
  // ride cannot be told, the home shows: nothing else depends on it. A ride
  // already followed stays as it is.
  Future<void> _onStarted(
    PassengerFlowStarted event,
    Emitter<PassengerFlowState> emit,
  ) async {
    if (state is PassengerFlowRide) return;
    if (await _loadCurrentRideUseCase() case Ok(value: final rideId?)) {
      emit(PassengerFlowRide(rideId: rideId));
      return;
    }
    if (state is PassengerFlowStarting) emit(const PassengerFlowHome());
  }

  // The home shows its error and "Réessayer" instead of the loader; once it
  // loads, PassengerFlowStarted looks for the ride again.
  void _onHomeFailed(
    PassengerHomeFailed event,
    Emitter<PassengerFlowState> emit,
  ) {
    if (state is PassengerFlowStarting) emit(const PassengerFlowHome());
  }

  // A notification may be a booked ride that started: the passenger must see
  // its search, its taxi, or that none was found. Without a ride in it, the
  // current ride is asked again.
  Future<void> _onPushesWatched(
    PassengerPushesWatched event,
    Emitter<PassengerFlowState> emit,
  ) async {
    if (_watchesPushes) return;
    _watchesPushes = true;
    await emit.onEach<String?>(
      _watchPushedRidesUseCase(),
      onData: (rideId) => add(
        rideId == null
            ? const PassengerFlowStarted()
            : _PassengerPushedRideOpened(rideId: rideId),
      ),
    );
  }

  // A ride already followed stays on screen, even for another ride's
  // notification.
  void _onPushedRideOpened(
    _PassengerPushedRideOpened event,
    Emitter<PassengerFlowState> emit,
  ) {
    if (state is PassengerFlowRide) return;
    emit(PassengerFlowRide(rideId: event.rideId));
  }

  void _onDestinationSearchOpened(
    PassengerDestinationSearchOpened event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      PassengerFlowDestinationSearch(
        scheduledPickup: state.scheduledPickup,
        pickupPlace: state.pickupPlace,
        passengerCount: state.passengerCount,
      ),
    );
  }

  void _onDestinationSelected(
    PassengerDestinationSelected event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      PassengerFlowTaxiChoice(
        destination: event.destination,
        scheduledPickup: state.scheduledPickup,
        pickupPlace: state.pickupPlace,
        passengerCount: state.passengerCount,
      ),
    );
  }

  void _onSavedPlaceEditOpened(
    PassengerSavedPlaceEditOpened event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      PassengerFlowSavedPlaceEdit(
        kind: event.kind,
        current: event.current,
        fromAccount: event.fromAccount,
        scheduledPickup: state.scheduledPickup,
        pickupPlace: state.pickupPlace,
        passengerCount: state.passengerCount,
      ),
    );
  }

  // From the home, the passenger tapped "Maison" to go there: the taxi
  // choice opens at once. Validated by the user, 2026-11-11.
  void _onSavedPlaceSaved(
    PassengerSavedPlaceSaved event,
    Emitter<PassengerFlowState> emit,
  ) {
    final currentState = state;
    if (currentState is! PassengerFlowSavedPlaceEdit) return;
    if (currentState.fromAccount) {
      emit(_home());
      return;
    }
    emit(
      PassengerFlowTaxiChoice(
        destination: event.place.toDestination(),
        scheduledPickup: state.scheduledPickup,
        pickupPlace: state.pickupPlace,
        passengerCount: state.passengerCount,
      ),
    );
  }

  void _onSavedPlaceDeleted(
    PassengerSavedPlaceDeleted event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(_home());
  }

  // The home no longer shows the pickup time: back to "Maintenant", so the
  // next destination never opens on a forgotten time (user's decision, spec
  // heure-de-prise-en-charge.md). The passengers go back to 1 the same way,
  // spec nombre-de-passagers.md. The pickup place is kept.
  PassengerFlowHome _home() =>
      PassengerFlowHome(pickupPlace: state.pickupPlace);

  // The ride page shows where the taxi comes; a ride opened at start or by a
  // notification falls back to where the phone is.
  void _onRideOrdered(
    PassengerRideOrdered event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      PassengerFlowRide(rideId: event.rideId, pickupPlace: state.pickupPlace),
    );
  }

  void _onRideEnded(
    PassengerRideEnded event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(const PassengerFlowHome());
  }

  void _onRideBooked(
    PassengerRideBooked event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(const PassengerFlowHome());
  }

  void _onPickupTimeSheetOpened(
    PassengerPickupTimeSheetOpened event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      _withPickup(
        scheduledPickup: state.scheduledPickup,
        pickupPlace: state.pickupPlace,
        pickupDays: _getPickupDaysUseCase(now: DateTime.now()),
      ),
    );
  }

  void _onPickupTimeChanged(
    PassengerPickupTimeChanged event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      _withPickup(
        scheduledPickup: event.scheduledPickup,
        pickupPlace: state.pickupPlace,
      ),
    );
  }

  void _onPickupPlaceChanged(
    PassengerPickupPlaceChanged event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      _withPickup(
        scheduledPickup: state.scheduledPickup,
        pickupPlace: event.pickupPlace,
      ),
    );
  }

  // Only the taxi choice shows the passengers: another screen has nothing to
  // change.
  void _onPassengerCountChanged(
    PassengerCountChanged event,
    Emitter<PassengerFlowState> emit,
  ) {
    final current = state;
    if (current is! PassengerFlowTaxiChoice) return;
    emit(
      PassengerFlowTaxiChoice(
        destination: current.destination,
        scheduledPickup: current.scheduledPickup,
        pickupPlace: current.pickupPlace,
        passengerCount: event.passengerCount,
      ),
    );
  }

  void _onBackPressed(
    PassengerFlowBackPressed event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      switch (state) {
        PassengerFlowTaxiChoice() => PassengerFlowDestinationSearch(
          scheduledPickup: state.scheduledPickup,
          pickupPlace: state.pickupPlace,
          passengerCount: state.passengerCount,
        ),
        // Leaving an ordered ride goes through "Annuler la course" only; the
        // start ends on its own.
        PassengerFlowRide() || PassengerFlowStarting() => state,
        _ => _home(),
      },
    );
  }

  // The same screen, with another pickup time, pickup days or pickup place.
  PassengerFlowState _withPickup({
    required DateTime? scheduledPickup,
    required Place? pickupPlace,
    List<PickupDay> pickupDays = const [],
  }) => switch (state) {
    PassengerFlowHome() => PassengerFlowHome(
      scheduledPickup: scheduledPickup,
      pickupDays: pickupDays,
      pickupPlace: pickupPlace,
      passengerCount: state.passengerCount,
    ),
    PassengerFlowDestinationSearch() => PassengerFlowDestinationSearch(
      scheduledPickup: scheduledPickup,
      pickupDays: pickupDays,
      pickupPlace: pickupPlace,
      passengerCount: state.passengerCount,
    ),
    PassengerFlowTaxiChoice(:final destination) => PassengerFlowTaxiChoice(
      destination: destination,
      scheduledPickup: scheduledPickup,
      pickupDays: pickupDays,
      pickupPlace: pickupPlace,
      passengerCount: state.passengerCount,
    ),
    // The pickup of an ordered ride can't change anymore; nothing to change
    // while starting, nor on a saved place's screen.
    PassengerFlowRide() ||
    PassengerFlowStarting() ||
    PassengerFlowSavedPlaceEdit() => state,
  };
}
