import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_documents_usecase.dart';

part 'driver_flow_event.dart';
part 'driver_flow_state.dart';

/// Drives the driver screens stack: the documents check at login, then home.
class DriverFlowBloc extends Bloc<DriverFlowEvent, DriverFlowState> {
  DriverFlowBloc({
    required LoadDriverDocumentsUseCase loadDriverDocumentsUseCase,
  }) : _loadDriverDocumentsUseCase = loadDriverDocumentsUseCase,
       super(const DriverFlowCheckingDocuments()) {
    on<DriverFlowStarted>(_onStarted);
    on<DriverDocumentsPostponed>(_onDocumentsPostponed);
    on<DriverRideAccepted>(_onRideAccepted);
    on<DriverArrivedAtPickup>(_onArrivedAtPickup);
    on<DriverRideStarted>(_onRideStarted);
    on<DriverNoShowReported>(_onNoShowReported);
    on<DriverRideFinished>(_onRideFinished);
    on<DriverRideCompleted>(_onRideCompleted);
    on<DriverDocumentsOpened>(_onDocumentsOpened);
    on<DriverDocumentsClosed>(_onDocumentsClosed);
  }

  final LoadDriverDocumentsUseCase _loadDriverDocumentsUseCase;

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

  void _onRideAccepted(
    DriverRideAccepted event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(DriverFlowPickup(ride: event.ride));
  }

  void _onArrivedAtPickup(
    DriverArrivedAtPickup event,
    Emitter<DriverFlowState> emit,
  ) {
    final currentState = state;
    if (currentState is! DriverFlowPickup) return;
    emit(
      DriverFlowBoarding(ride: currentState.ride, arrivedAt: DateTime.now()),
    );
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
    emit(
      DriverFlowCheckout(
        ride: currentState.ride,
        meterCents: event.meterCents,
        distanceKm: event.distanceKm,
      ),
    );
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
