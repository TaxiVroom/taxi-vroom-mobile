import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/pickup_day.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_current_ride_usecase.dart';

part 'passenger_flow_event.dart';
part 'passenger_flow_state.dart';

/// Drives the passenger screens stack (home → destination → taxi choice) and
/// remembers the pickup time chosen along the way.
class PassengerFlowBloc extends Bloc<PassengerFlowEvent, PassengerFlowState> {
  PassengerFlowBloc({
    required GetPickupDaysUseCase getPickupDaysUseCase,
    required LoadCurrentRideUseCase loadCurrentRideUseCase,
  }) : _getPickupDaysUseCase = getPickupDaysUseCase,
       _loadCurrentRideUseCase = loadCurrentRideUseCase,
       super(const PassengerFlowHome()) {
    on<PassengerFlowStarted>(_onStarted);
    on<PassengerDestinationSearchOpened>(_onDestinationSearchOpened);
    on<PassengerDestinationSelected>(_onDestinationSelected);
    on<PassengerRideOrdered>(_onRideOrdered);
    on<PassengerRideEnded>(_onRideEnded);
    on<PassengerRideBooked>(_onRideBooked);
    on<PassengerPickupTimeSheetOpened>(_onPickupTimeSheetOpened);
    on<PassengerPickupTimeChanged>(_onPickupTimeChanged);
    on<PassengerFlowBackPressed>(_onBackPressed);
  }

  final GetPickupDaysUseCase _getPickupDaysUseCase;
  final LoadCurrentRideUseCase _loadCurrentRideUseCase;

  // If it cannot be told, the home stays: nothing else depends on it.
  Future<void> _onStarted(
    PassengerFlowStarted event,
    Emitter<PassengerFlowState> emit,
  ) async {
    if (await _loadCurrentRideUseCase() case Ok(value: final rideId?)) {
      emit(PassengerFlowRide(rideId: rideId));
    }
  }

  void _onDestinationSearchOpened(
    PassengerDestinationSearchOpened event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      PassengerFlowDestinationSearch(scheduledPickup: state.scheduledPickup),
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
      ),
    );
  }

  void _onRideOrdered(
    PassengerRideOrdered event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(PassengerFlowRide(rideId: event.rideId));
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
        pickupDays: _getPickupDaysUseCase(now: DateTime.now()),
      ),
    );
  }

  void _onPickupTimeChanged(
    PassengerPickupTimeChanged event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(_withPickup(scheduledPickup: event.scheduledPickup));
  }

  void _onBackPressed(
    PassengerFlowBackPressed event,
    Emitter<PassengerFlowState> emit,
  ) {
    emit(
      switch (state) {
        PassengerFlowTaxiChoice() => PassengerFlowDestinationSearch(
          scheduledPickup: state.scheduledPickup,
        ),
        // Leaving an ordered ride goes through "Annuler la course" only.
        PassengerFlowRide() => state,
        _ => PassengerFlowHome(scheduledPickup: state.scheduledPickup),
      },
    );
  }

  // The same screen, with another pickup time or pickup days.
  PassengerFlowState _withPickup({
    required DateTime? scheduledPickup,
    List<PickupDay> pickupDays = const [],
  }) => switch (state) {
    PassengerFlowHome() => PassengerFlowHome(
      scheduledPickup: scheduledPickup,
      pickupDays: pickupDays,
    ),
    PassengerFlowDestinationSearch() => PassengerFlowDestinationSearch(
      scheduledPickup: scheduledPickup,
      pickupDays: pickupDays,
    ),
    PassengerFlowTaxiChoice(:final destination) => PassengerFlowTaxiChoice(
      destination: destination,
      scheduledPickup: scheduledPickup,
      pickupDays: pickupDays,
    ),
    // The pickup time of an ordered ride can't change anymore.
    PassengerFlowRide() => state,
  };
}
