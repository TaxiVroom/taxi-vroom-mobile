import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/arrive_at_pickup_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_current_driver_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_documents_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/submit_driver_document_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_document_notifications_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_passenger_cancellation_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';

part 'driver_flow_event.dart';
part 'driver_flow_state.dart';

/// Drives the driver screens stack: home, the documents when one blocks or
/// when opened, and the ride. Spec
/// taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
class DriverFlowBloc extends Bloc<DriverFlowEvent, DriverFlowState> {
  DriverFlowBloc({
    required LoadCurrentDriverRideUseCase loadCurrentDriverRideUseCase,
    required LoadDriverDocumentsUseCase loadDriverDocumentsUseCase,
    required SubmitDriverDocumentUseCase submitDriverDocumentUseCase,
    required WatchDocumentNotificationsUseCase
    watchDocumentNotificationsUseCase,
    required ArriveAtPickupUseCase arriveAtPickupUseCase,
    required WithdrawFromRideUseCase withdrawFromRideUseCase,
    required WatchPassengerCancellationUseCase
    watchPassengerCancellationUseCase,
  }) : _loadCurrentDriverRideUseCase = loadCurrentDriverRideUseCase,
       _loadDriverDocumentsUseCase = loadDriverDocumentsUseCase,
       _watchDocumentNotificationsUseCase = watchDocumentNotificationsUseCase,
       _submitDriverDocumentUseCase = submitDriverDocumentUseCase,
       _arriveAtPickupUseCase = arriveAtPickupUseCase,
       _withdrawFromRideUseCase = withdrawFromRideUseCase,
       _watchPassengerCancellationUseCase = watchPassengerCancellationUseCase,
       super(const DriverFlowCheckingDocuments()) {
    on<DriverFlowStarted>(_onStarted);
    on<_DriverCurrentRideFound>(_onCurrentRideFound);
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
    on<DriverDocumentsBlocked>(_onDocumentsBlocked);
    on<DriverDocumentsRefreshed>(_onDocumentsRefreshed);
    on<DriverDocumentSubmitted>(_onDocumentSubmitted);
    on<DriverDocumentNotificationsWatched>(_onDocumentNotificationsWatched);
  }

  final LoadCurrentDriverRideUseCase _loadCurrentDriverRideUseCase;
  final LoadDriverDocumentsUseCase _loadDriverDocumentsUseCase;
  final SubmitDriverDocumentUseCase _submitDriverDocumentUseCase;
  final WatchDocumentNotificationsUseCase _watchDocumentNotificationsUseCase;

  // The last documents read, for the home's banner.
  DriverDocuments? _documents;
  final ArriveAtPickupUseCase _arriveAtPickupUseCase;
  final WithdrawFromRideUseCase _withdrawFromRideUseCase;
  final WatchPassengerCancellationUseCase _watchPassengerCancellationUseCase;

  Future<void> _onStarted(
    DriverFlowStarted event,
    Emitter<DriverFlowState> emit,
  ) async {
    emit(const DriverFlowCheckingDocuments());
    // A ride comes first: the passenger waits. If it cannot be told, the app
    // starts as usual.
    if (await _loadCurrentDriverRideUseCase() case Ok(
      value: final current?,
    )) {
      add(_DriverCurrentRideFound(current: current));
      return;
    }
    // A document to send: "Vos documents" opens at once (decision of the
    // user, 2026-11-10); one waiting for the admin does not (2026-11-11).
    await _readDocuments();
    emit(_homeOrDocuments());
  }

  DriverFlowState _homeOrDocuments() {
    final documents = _documents;
    if (documents != null && documents.hasDocumentToSend) {
      return DriverFlowDocuments(documents: documents);
    }
    return _home();
  }

  DriverFlowHome _home({String? notice}) =>
      DriverFlowHome(notice: notice, documents: _documents);

  // Unread: the home simply shows no banner.
  Future<void> _readDocuments() async {
    if (await _loadDriverDocumentsUseCase() case Ok(:final value)) {
      _documents = value;
    }
  }

  Future<void> _onDocumentsBlocked(
    DriverDocumentsBlocked event,
    Emitter<DriverFlowState> emit,
  ) async {
    // A loader over the home until "Vos documents" opens.
    emit(const DriverFlowCheckingDocuments(isOverHome: true));
    await _readDocuments();
    final documents = _documents;
    emit(
      documents == null ? _home() : DriverFlowDocuments(documents: documents),
    );
  }

  Future<void> _onDocumentsRefreshed(
    DriverDocumentsRefreshed event,
    Emitter<DriverFlowState> emit,
  ) async {
    // Never over a ride, nor while a document is being sent.
    if (!_showsHomeOrDocuments) return;
    // "Vos documents" on screen: a loader instead of the old states. The
    // home shows none: its decision only comes after the answer.
    switch (state) {
      case DriverFlowDocuments(:final documents):
        emit(DriverFlowDocuments(documents: documents, isRefreshing: true));
      case DriverFlowDocumentsReview(:final documents):
        emit(
          DriverFlowDocumentsReview(documents: documents, isRefreshing: true),
        );
      case _:
        break;
    }
    await _readDocuments();
    final documents = _documents;
    switch (state) {
      case DriverFlowHome():
        emit(_homeOrDocuments());
      // Opened by the driver: updated, it stays open. Unread, the states
      // it showed come back without the loader.
      case DriverFlowDocumentsReview(
        sendingTypeId: null,
        documents: final shown,
      ):
        emit(DriverFlowDocumentsReview(documents: documents ?? shown));
      // Opened for a problem: once it is gone, the home. Spec
      // taxi-vroom-api/docs/specs/documents-du-chauffeur.md, step 6 bis.
      case DriverFlowDocuments(sendingTypeId: null):
        emit(_homeOrDocuments());
      case _:
        break;
    }
  }

  bool get _showsHomeOrDocuments => switch (state) {
    DriverFlowHome() => true,
    DriverFlowDocuments(:final sendingTypeId) => sendingTypeId == null,
    DriverFlowDocumentsReview(:final sendingTypeId) => sendingTypeId == null,
    _ => false,
  };

  // A notification about the documents, received or tapped: read again.
  Future<void> _onDocumentNotificationsWatched(
    DriverDocumentNotificationsWatched event,
    Emitter<DriverFlowState> emit,
  ) => emit.onEach<void>(
    _watchDocumentNotificationsUseCase(),
    onData: (_) => add(const DriverDocumentsRefreshed()),
  );

  // Sent: shown "en vérification" once read again.
  Future<void> _onDocumentSubmitted(
    DriverDocumentSubmitted event,
    Emitter<DriverFlowState> emit,
  ) async {
    final current = _documents;
    if (current == null) return;
    final isReview = state is DriverFlowDocumentsReview;
    emit(
      _documentsState(
        current,
        isReview: isReview,
        sendingTypeId: event.documentTypeId,
      ),
    );
    final result = await _submitDriverDocumentUseCase(
      documentTypeId: event.documentTypeId,
      frontFilePath: event.frontFilePath,
      backFilePath: event.backFilePath,
      expiresAt: event.expiresAt,
    );
    await _readDocuments();
    final documents = _documents ?? current;
    emit(
      _documentsState(
        documents,
        isReview: isReview,
        failureMessage: result is Error<void> ? result.error.message : null,
      ),
    );
  }

  DriverFlowState _documentsState(
    DriverDocuments documents, {
    required bool isReview,
    String? sendingTypeId,
    String? failureMessage,
  }) => isReview
      ? DriverFlowDocumentsReview(
          documents: documents,
          isSubmitting: sendingTypeId != null,
          sendingTypeId: sendingTypeId,
          failureMessage: failureMessage,
        )
      : DriverFlowDocuments(
          documents: documents,
          isSubmitting: sendingTypeId != null,
          sendingTypeId: sendingTypeId,
          failureMessage: failureMessage,
        );

  Future<void> _onCurrentRideFound(
    _DriverCurrentRideFound event,
    Emitter<DriverFlowState> emit,
  ) async {
    final ride = event.current.ride;
    switch (event.current) {
      case CurrentRideAtPickup():
        emit(DriverFlowPickup(ride: ride));
      case CurrentRideAtBoarding(:final arrivedAt):
        emit(DriverFlowBoarding(ride: ride, arrivedAt: arrivedAt));
      case CurrentRideInProgress():
        emit(DriverFlowInRide(ride: ride));
        return;
    }
    await _watchPassengerCancellation(ride, emit);
  }

  void _onDocumentsPostponed(
    DriverDocumentsPostponed event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(_home());
  }

  // Until the passenger is in, they may cancel: listened to until the ride is
  // no longer the driver's.
  Future<void> _onRideAccepted(
    DriverRideAccepted event,
    Emitter<DriverFlowState> emit,
  ) async {
    final ride = event.ride;
    emit(DriverFlowPickup(ride: ride));
    await _watchPassengerCancellation(ride, emit);
  }

  Future<void> _watchPassengerCancellation(
    DriverRide ride,
    Emitter<DriverFlowState> emit,
  ) => emit.onEach<void>(
    _watchPassengerCancellationUseCase(ride.id),
    onData: (_) => add(_DriverRideCancelledByPassenger(rideId: ride.id)),
  );

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
        Ok() => _home(),
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
    emit(_home());
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
    emit(_home(notice: 'Le client a annulé la course.'));
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
    emit(_home());
  }

  void _onNoShowReported(
    DriverNoShowReported event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(_home());
  }

  void _onDocumentsOpened(
    DriverDocumentsOpened event,
    Emitter<DriverFlowState> emit,
  ) {
    _documents = event.documents;
    emit(DriverFlowDocumentsReview(documents: event.documents));
  }

  void _onDocumentsClosed(
    DriverDocumentsClosed event,
    Emitter<DriverFlowState> emit,
  ) {
    emit(_home());
  }
}
