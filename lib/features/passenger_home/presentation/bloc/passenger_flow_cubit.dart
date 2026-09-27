import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/pickup_day.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';

part 'passenger_flow_state.dart';

/// Drives the passenger screens stack (home → destination → taxi choice) and
/// remembers the pickup time chosen along the way.
class PassengerFlowCubit extends Cubit<PassengerFlowState> {
  PassengerFlowCubit({required GetPickupDaysUseCase getPickupDaysUseCase})
    : _getPickupDaysUseCase = getPickupDaysUseCase,
      super(const PassengerFlowHome());

  final GetPickupDaysUseCase _getPickupDaysUseCase;

  List<PickupDay> availablePickupDays() =>
      _getPickupDaysUseCase(now: DateTime.now());

  void destinationSearchOpened() => emit(
    PassengerFlowDestinationSearch(scheduledPickup: state.scheduledPickup),
  );

  void destinationSelected(Place destination) => emit(
    PassengerFlowTaxiChoice(
      destination: destination,
      scheduledPickup: state.scheduledPickup,
    ),
  );

  void rideRequested(String rideId) => emit(PassengerFlowRide(rideId: rideId));

  // Back to a fresh home once the ride is over or cancelled.
  void rideEnded() => emit(const PassengerFlowHome());

  // A booking waits in "Mes courses": back to a fresh home.
  void rideBooked() => emit(const PassengerFlowHome());

  void pickupTimeChanged(DateTime? scheduledPickup) => emit(
    switch (state) {
      PassengerFlowHome() => PassengerFlowHome(
        scheduledPickup: scheduledPickup,
      ),
      PassengerFlowDestinationSearch() => PassengerFlowDestinationSearch(
        scheduledPickup: scheduledPickup,
      ),
      PassengerFlowTaxiChoice(:final destination) => PassengerFlowTaxiChoice(
        destination: destination,
        scheduledPickup: scheduledPickup,
      ),
      // The pickup time of an ordered ride can't change anymore.
      PassengerFlowRide() => state,
    },
  );

  void backPressed() => emit(
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
