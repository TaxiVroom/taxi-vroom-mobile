import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_for_arrival_usecase.dart';

part 'arrival_pickup_state.dart';

/// "Arriver à" : the pickup time matching the arrival time chosen by the
/// passenger, for the current trip.
class ArrivalPickupCubit extends Cubit<ArrivalPickupState> {
  ArrivalPickupCubit({
    required Coordinates origin,
    required Coordinates destination,
    required GetPickupForArrivalUseCase getPickupForArrivalUseCase,
  }) : _origin = origin,
       _destination = destination,
       _getPickupForArrivalUseCase = getPickupForArrivalUseCase,
       super(const ArrivalPickupIdle());

  final Coordinates _origin;
  final Coordinates _destination;
  final GetPickupForArrivalUseCase _getPickupForArrivalUseCase;

  Future<void> arrivalChanged(DateTime arrival) async {
    emit(ArrivalPickupLoading(arrival: arrival));
    final result = await _getPickupForArrivalUseCase(
      from: _origin,
      to: _destination,
      arrival: arrival,
      now: DateTime.now(),
    );
    // The passenger may have picked another arrival time meanwhile.
    if (isClosed || state.arrival != arrival) return;
    emit(
      switch (result) {
        Ok(:final value) => ArrivalPickupReady(
          arrival: arrival,
          pickup: value,
        ),
        Error(:final error) => ArrivalPickupFailure(
          arrival: arrival,
          message: error.message,
        ),
      },
    );
  }
}
