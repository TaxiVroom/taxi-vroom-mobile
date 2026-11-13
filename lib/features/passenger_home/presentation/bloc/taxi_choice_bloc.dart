import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/usecases/book_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/offer_from_pickup_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/request_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';

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
    required WatchNearbyTaxisUseCase watchNearbyTaxisUseCase,
    Place? pickupPlace,
  }) : _origin = origin,
       _pickupPlace = pickupPlace,
       _destination = destination,
       _loadTaxiChoiceUseCase = loadTaxiChoiceUseCase,
       _requestRideUseCase = requestRideUseCase,
       _bookRideUseCase = bookRideUseCase,
       _offerFromPickupUseCase = offerFromPickupUseCase,
       _watchNearbyTaxisUseCase = watchNearbyTaxisUseCase,
       super(const TaxiChoiceLoading()) {
    on<TaxiChoiceStarted>(_onStarted);
    on<TaxiOfferSelected>(_onOfferSelected);
    on<TaxiRideOrdered>(_onRideOrdered);
    on<TaxiRideBooked>(_onRideBooked);
    on<_TaxiChoiceFreeTaxiSeen>(_onFreeTaxiSeen);
  }

  // Where the price shown was estimated from; the pickup confirmed before
  // ordering, once it moved.
  Coordinates _origin;

  // The pickup place chosen, named with its Mapbox address; null for
  // "Position actuelle", named from where the phone is.
  Place? _pickupPlace;
  final Place _destination;

  // Null for a taxi now; otherwise the ride is priced for it and booked.
  // Set by each TaxiChoiceStarted: the passenger may change it on screen.
  DateTime? _scheduledPickup;

  // How many people travel; set by each TaxiChoiceStarted, like the time.
  int _passengerCount = 1;
  final LoadTaxiChoiceUseCase _loadTaxiChoiceUseCase;
  final RequestRideUseCase _requestRideUseCase;
  final BookRideUseCase _bookRideUseCase;
  final OfferFromPickupUseCase _offerFromPickupUseCase;
  final WatchNearbyTaxisUseCase _watchNearbyTaxisUseCase;

  // Followed while no taxi is free for a ride now.
  StreamSubscription<Result<List<NearbyTaxi>>>? _freeTaxis;

  Future<void> _onStarted(
    TaxiChoiceStarted event,
    Emitter<TaxiChoiceState> emit,
  ) async {
    _scheduledPickup = event.scheduledPickup;
    _passengerCount = event.passengerCount;
    emit(const TaxiChoiceLoading());
    await _load(emit);
  }

  // A new estimate each time: the backend prices from the taxis free now, or
  // at the tariff of the pickup time for a booking.
  Future<void> _load(
    Emitter<TaxiChoiceState> emit, {
    String? orderFailureMessage,
  }) async {
    _stopWatchingFreeTaxis();
    switch (await _loadTaxiChoiceUseCase(
      from: _origin,
      pickupPlace: _pickupPlace,
      to: _destination,
      passengerCount: _passengerCount,
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
        if (value.offers.isEmpty && _scheduledPickup == null) {
          _watchFreeTaxis();
        }
      case Error(:final error):
        emit(TaxiChoiceFailure(message: error.message));
    }
  }

  // No taxi free for a ride now: the first one free around the pickup
  // brings the estimate, without the passenger touching anything. Spec
  // heure-de-prise-en-charge.md, "Un taxi qui se libère". The taxis already
  // free at the first answer could not take the ride (too few seats for the
  // passengers): only another taxi brings a new estimate, or the screen would
  // estimate again for ever. Spec nombre-de-passagers.md, situation 4.
  void _watchFreeTaxis() {
    final known = <String>{};
    var isFirstAnswer = true;
    _freeTaxis = _watchNearbyTaxisUseCase(around: _origin).listen((result) {
      if (result is! Ok<List<NearbyTaxi>>) return;
      final taxis = result.value;
      if (isFirstAnswer) {
        isFirstAnswer = false;
        known.addAll(taxis.map((taxi) => taxi.id));
        return;
      }
      if (WatchNearbyTaxisUseCase.hasNewTaxi(taxis, known: known)) {
        add(const _TaxiChoiceFreeTaxiSeen());
      }
    });
  }

  // Not awaited: the watch follows the GPS through an `await for`
  // (WatchNearbyTaxisUseCase.searchCenters), whose cancel waits for the next
  // position, which may never come; awaiting it froze the loader forever.
  void _stopWatchingFreeTaxis() {
    unawaited(_freeTaxis?.cancel());
    _freeTaxis = null;
  }

  // Ignored once the passenger chose a pickup time meanwhile.
  Future<void> _onFreeTaxiSeen(
    _TaxiChoiceFreeTaxiSeen event,
    Emitter<TaxiChoiceState> emit,
  ) async {
    if (_freeTaxis == null || _scheduledPickup != null) return;
    emit(const TaxiChoiceLoading());
    await _load(emit);
  }

  @override
  Future<void> close() async {
    _stopWatchingFreeTaxis();
    return super.close();
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
  Future<Result<TaxiOffer>> _offerAt(TaxiOffer shown, Place pickup) async {
    final result = await _offerFromPickupUseCase(
      shown: shown,
      pricedFrom: _origin,
      pickup: pickup,
      destination: _destination,
      passengerCount: _passengerCount,
      scheduledPickup: _scheduledPickup,
    );
    if (result case Ok(:final value) when value != shown) {
      _origin = pickup.coordinates;
      _pickupPlace = pickup;
    }
    return result;
  }
}
