import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/arrive_at_pickup_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_documents_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_passenger_cancellation_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';

part 'driver_flow_event.dart';
part 'driver_flow_state.dart';

/// Drives the driver screens stack: the documents check at login, then home.
class DriverFlowBloc extends Bloc<DriverFlowEvent, DriverFlowState> {
  DriverFlowBloc({
    required LoadDriverDocumentsUseCase loadDriverDocumentsUseCase,
    required ArriveAtPickupUseCase arriveAtPickupUseCase,
    required WithdrawFromRideUseCase withdrawFromRideUseCase,
    required WatchPassengerCancellationUseCase
    watchPassengerCancellationUseCase,
  }) : _loadDriverDocumentsUseCase = loadDriverDocumentsUseCase,
       _arriveAtPickupUseCase = arriveAtPickupUseCase,
       _withdrawFromRideUseCase = withdrawFromRideUseCase,
       _watchPassengerCancellationUseCase = watchPassengerCancellationUseCase,
       super(const DriverFlowCheckingDocuments()) {
    on<DriverFlowStarted>(_onStarted);
    on<DriverDocumentsPostponed>(_onDocumentsPostponed);
    on<DriverRideAccepted>(_onRideAccepted);
    on<DriverArrivedAtPickup>(_onArrivedAtPickup);
    on<DriverWithdrawRequested>(_onWithdrawRequested);
    on<DriverRideWithdrawn>(_onRideWithdrawn);
    on<_DriverRideCancelledByPassenger>(_onRideCancelledByPassenger);
    on<DriverRideStarted>(_onRideStarted);
    on<DriverNoShowReported>(_onNoShowReported);
    on<DriverRideFinished>(_onRideFinished);
    on<DriverRideResumed>(_onRideResumed);
    on<DriverRideCompleted>(_onRideCompleted);
    on<DriverDocumentsOpened>(_onDocumentsOpened);
    on<DriverDocumentsClosed>(_onDocumentsClosed);
  }

  final LoadDriverDocumentsUseCase _loadDriverDocumentsUseCase;
  final ArriveAtPickupUseCase _arriveAtPickupUseCase;
  final WithdrawFromRideUseCase _withdrawFromRideUseCase;
  final WatchPassengerCancellationUseCase _watchPassengerCancellationUseCase;

  Future<void> _onStarted(
    DriverFlowStarted event,
    Emitter<DriverFlowState> emit,
  ) async {
    emit(const DriverFlowCheckingDocuments());
    final result = await _loadDriverDocumentsUseCase();
    emit(
      switch (result) {
        Ok(:final value) when value.needsAction => DriverFlowDocuments(
          documents: value,
        ),
        Ok() => const DriverFlowHome(),
        Error(:final error) => DriverFlowDocumentsFailure(
          message: error.message,
        ),
      },
    );
  }

  void _onDocumentsPostponed(
    DriverDocumentsPostponed event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(const DriverFlowHome());
  }

  // Until the passenger is in, they may cancel: listened to until the ride is
  // no longer the driver's.
  Future<void> _onRideAccepted(
    DriverRideAccepted event,
    Emitter<DriverFlowState> emit,
  ) async {
    final ride = event.ride;
    emit(DriverFlowPickup(ride: ride));
    await emit.onEach<void>(
      _watchPassengerCancellationUseCase(ride.id),
      onData: (_) => add(_DriverRideCancelledByPassenger(rideId: ride.id)),
    );
  }

  Future<void> _onArrivedAtPickup(
    DriverArrivedAtPickup event,
    Emitter<DriverFlowState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverFlowPickup || currentState.isSubmitting) return;

    final ride = currentState.ride;
    emit(DriverFlowPickup(ride: ride, isSubmitting: true));
    final result = await _arriveAtPickupUseCase(ride.id);
    emit(
      switch (result) {
        Ok() => DriverFlowBoarding(ride: ride, arrivedAt: DateTime.now()),
        Error(:final error) => DriverFlowPickup(
          ride: ride,
          failureMessage: error.message,
        ),
      },
    );
  }

  Future<void> _onWithdrawRequested(
    DriverWithdrawRequested event,
    Emitter<DriverFlowState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverFlowPickup || currentState.isSubmitting) return;

    final ride = currentState.ride;
    emit(DriverFlowPickup(ride: ride, isSubmitting: true));
    final result = await _withdrawFromRideUseCase(ride.id);
    emit(
      switch (result) {
        Ok() => const DriverFlowHome(),
        Error(:final error) => DriverFlowPickup(
          ride: ride,
          failureMessage: error.message,
        ),
      },
    );
  }

  void _onRideWithdrawn(
    DriverRideWithdrawn event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(const DriverFlowHome());
  }

  void _onRideCancelledByPassenger(
    _DriverRideCancelledByPassenger event,
    Emitter<DriverFlowState> emit,
  ) {
    final ride = switch (state) {
      DriverFlowPickup(:final ride) || DriverFlowBoarding(:final ride) => ride,
      _ => null,
    };
    if (ride?.id != event.rideId) return;
    emit(const DriverFlowHome(notice: 'Le client a annulé la course.'));
  }

  void _onRideStarted(DriverRideStarted event, Emitter<DriverFlowState> emit) {
    final currentState = state;
    if (currentState is! DriverFlowBoarding) return;
    emit(DriverFlowInRide(ride: currentState.ride));
  }

  void _onRideFinished(
    DriverRideFinished event,
    Emitter<DriverFlowState> emit,
  ) {
    final currentState = state;
    if (currentState is! DriverFlowInRide) return;
    emit(DriverFlowCheckout(ride: currentState.ride));
  }

  // Possible until "Valider et repasser libre": the server still has the ride
  // in progress.
  void _onRideResumed(DriverRideResumed event, Emitter<DriverFlowState> emit) {
    final currentState = state;
    if (currentState is! DriverFlowCheckout) return;
    emit(DriverFlowInRide(ride: currentState.ride));
  }

  // Free again: back to the home, online.
  void _onRideCompleted(
    DriverRideCompleted event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(const DriverFlowHome());
  }

  void _onNoShowReported(
    DriverNoShowReported event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(const DriverFlowHome());
  }

  void _onDocumentsOpened(
    DriverDocumentsOpened event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(DriverFlowDocumentsReview(documents: event.documents));
  }

  void _onDocumentsClosed(
    DriverDocumentsClosed event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(const DriverFlowHome());
  }
}
