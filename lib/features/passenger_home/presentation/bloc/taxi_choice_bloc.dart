import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/offer_from_pickup_usecase.dart';
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
    required OfferFromPickupUseCase offerFromPickupUseCase,
  }) : _origin = origin,
       _destination = destination,
       _loadTaxiChoiceUseCase = loadTaxiChoiceUseCase,
       _requestRideUseCase = requestRideUseCase,
       _bookRideUseCase = bookRideUseCase,
       _offerFromPickupUseCase = offerFromPickupUseCase,
       super(const TaxiChoiceLoading()) {
    on<TaxiChoiceStarted>(_onStarted);
    on<TaxiOfferSelected>(_onOfferSelected);
    on<TaxiRideOrdered>(_onRideOrdered);
    on<TaxiRideBooked>(_onRideBooked);
  }

  // Where the price shown was estimated from; the pickup confirmed before
  // ordering, once it moved.
  Coordinates _origin;
  final Place _destination;

  // Null for a taxi now; otherwise the ride is priced for it and booked.
  // Set by each TaxiChoiceStarted: the passenger may change it on screen.
  DateTime? _scheduledPickup;
  final LoadTaxiChoiceUseCase _loadTaxiChoiceUseCase;
  final RequestRideUseCase _requestRideUseCase;
  final BookRideUseCase _bookRideUseCase;
  final OfferFromPickupUseCase _offerFromPickupUseCase;

  Future<void> _onStarted(
    TaxiChoiceStarted event,
    Emitter<TaxiChoiceState> emit,
  ) async {
    _scheduledPickup = event.scheduledPickup;
    emit(const TaxiChoiceLoading());
    await _load(emit);
  }

  // A new estimate each time: the backend prices from the taxis free now, or
  // at the tariff of the pickup time for a booking.
  Future<void> _load(
    Emitter<TaxiChoiceState> emit, {
    String? orderFailureMessage,
  }) async {
    switch (await _loadTaxiChoiceUseCase(
      from: _origin,
      to: _destination,
      scheduledPickup: _scheduledPickup,
    )) {
      case Ok(:final value):
        emit(
          TaxiChoiceReady(
            choice: value,
            selectedOfferId: value.offers.firstOrNull?.id,
            orderFailureMessage: orderFailureMessage,
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
    final ordered = switch (await _offerAt(offer, event.pickup)) {
      Ok(:final value) => await _requestRideUseCase(value),
      Error(:final error) => Result<String>.error(error),
    };
    switch (ordered) {
      case Ok(:final value):
        emit(
          TaxiChoiceReady(
            choice: currentState.choice,
            selectedOfferId: offer.id,
            orderedRideId: value,
          ),
        );
      // The passenger sees the new price before ordering again.
      case Error(error: EstimateExpiredFailure(:final message)):
        await _load(emit, orderFailureMessage: message);
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
    final booked = switch (await _offerAt(offer, event.pickup)) {
      Ok(:final value) => await _bookRideUseCase(value),
      Error(:final error) => Result<String>.error(error),
    };
    switch (booked) {
      case Ok(:final value):
        emit(
          TaxiChoiceReady(
            choice: currentState.choice,
            selectedOfferId: offer.id,
            bookedRideId: value,
          ),
        );
      // The passenger sees the new price before booking again.
      case Error(error: EstimateExpiredFailure(:final message)):
        await _load(emit, orderFailureMessage: message);
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

  // The offer at the pickup confirmed. Priced again from there when it
  // moved, so the later estimates start from there too.
  Future<Result<TaxiOffer>> _offerAt(
    TaxiOffer shown,
    Coordinates pickup,
  ) async {
    final result = await _offerFromPickupUseCase(
      shown: shown,
      pricedFrom: _origin,
      pickup: pickup,
      destination: _destination,
      scheduledPickup: _scheduledPickup,
    );
    if (result case Ok(:final value) when value != shown) _origin = pickup;
    return result;
  }
}
