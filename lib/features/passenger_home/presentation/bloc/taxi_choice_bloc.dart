import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';

part 'taxi_choice_event.dart';
part 'taxi_choice_state.dart';

class TaxiChoiceBloc extends Bloc<TaxiChoiceEvent, TaxiChoiceState> {
  TaxiChoiceBloc({
    required Coordinates origin,
    required Place destination,
    required LoadTaxiChoiceUseCase loadTaxiChoiceUseCase,
    required RequestRideUseCase requestRideUseCase,
    required BookRideUseCase bookRideUseCase,
  }) : _origin = origin,
       _destination = destination,
       _loadTaxiChoiceUseCase = loadTaxiChoiceUseCase,
       _requestRideUseCase = requestRideUseCase,
       _bookRideUseCase = bookRideUseCase,
       super(const TaxiChoiceLoading()) {
    on<TaxiChoiceStarted>(_onStarted);
    on<TaxiOfferSelected>(_onOfferSelected);
    on<TaxiRideOrdered>(_onRideOrdered);
    on<TaxiRideBooked>(_onRideBooked);
  }

  final Coordinates _origin;
  final Place _destination;
  final LoadTaxiChoiceUseCase _loadTaxiChoiceUseCase;
  final RequestRideUseCase _requestRideUseCase;
  final BookRideUseCase _bookRideUseCase;

  Future<void> _onStarted(
    TaxiChoiceStarted event,
    Emitter<TaxiChoiceState> emit,
  ) async {
    emit(const TaxiChoiceLoading());
    switch (await _loadTaxiChoiceUseCase(from: _origin, to: _destination)) {
      case Ok(:final value):
        emit(
          TaxiChoiceReady(
            choice: value,
            selectedOfferId: value.offers.firstOrNull?.id,
          ),
        );
      case Error(:final error):
        emit(TaxiChoiceFailure(message: error.message));
    }
  }

  void _onOfferSelected(
    TaxiOfferSelected event,
    Emitter<TaxiChoiceState> emit,
  ) {
    final currentState = state;
    if (currentState is! TaxiChoiceReady) return;
    emit(
      TaxiChoiceReady(
        choice: currentState.choice,
        selectedOfferId: event.offerId,
      ),
    );
  }

  Future<void> _onRideOrdered(
    TaxiRideOrdered event,
    Emitter<TaxiChoiceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaxiChoiceReady || currentState.isOrdering) return;
    final offer = currentState.choice.offerById(currentState.selectedOfferId);
    if (offer == null) return;

    emit(
      TaxiChoiceReady(
        choice: currentState.choice,
        selectedOfferId: offer.id,
        isOrdering: true,
      ),
    );
    switch (await _requestRideUseCase(
      origin: _origin,
      destination: _destination,
      offer: offer,
    )) {
      case Ok(:final value):
        emit(
          TaxiChoiceReady(
            choice: currentState.choice,
            selectedOfferId: offer.id,
            orderedRideId: value,
          ),
        );
      case Error(:final error):
        emit(
          TaxiChoiceReady(
            choice: currentState.choice,
            selectedOfferId: offer.id,
            orderFailureMessage: error.message,
          ),
        );
    }
  }

  Future<void> _onRideBooked(
    TaxiRideBooked event,
    Emitter<TaxiChoiceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaxiChoiceReady || currentState.isOrdering) return;
    final offer = currentState.choice.offerById(currentState.selectedOfferId);
    if (offer == null) return;

    emit(
      TaxiChoiceReady(
        choice: currentState.choice,
        selectedOfferId: offer.id,
        isOrdering: true,
      ),
    );
    switch (await _bookRideUseCase(
      origin: _origin,
      destination: _destination,
      offer: offer,
      scheduledPickup: event.scheduledPickup,
    )) {
      case Ok(:final value):
        emit(
          TaxiChoiceReady(
            choice: currentState.choice,
            selectedOfferId: offer.id,
            bookedRideId: value,
          ),
        );
      case Error(:final error):
        emit(
          TaxiChoiceReady(
            choice: currentState.choice,
            selectedOfferId: offer.id,
            orderFailureMessage: error.message,
          ),
        );
    }
  }
}
