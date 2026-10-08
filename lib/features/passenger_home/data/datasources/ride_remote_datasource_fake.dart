import 'dart:math';

import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/ride_history_model.dart';
import 'package:mobile/features/passenger_home/data/models/ride_model.dart';

/// Implémentation de développement avec données de test.
/// Simule une course complète : recherche, chauffeur qui approche, trajet avec
/// le compteur qui tourne, puis fin de course. Une « minute » dure 3 s.
/// Garde aussi en mémoire les réservations et l'historique des courses.
class RideRemoteDataSourceFake implements RideRemoteDataSource {
  RideRemoteDataSourceFake() {
    final now = DateTime.now();
    _pastRides.addAll([
      _pastRideJson(
        'Gare',
        'Maison',
        now.subtract(const Duration(days: 2)),
        'A',
        1120,
      ),
      _pastRideJson(
        'Maison',
        'Travail',
        now.subtract(const Duration(days: 5)),
        'A',
        2190,
      ),
      _pastRideJson(
        'Rivétoile',
        'Maison',
        now.subtract(const Duration(days: 15)),
        'C',
        980,
      ),
    ]);

    final today = DateTime(now.year, now.month, now.day);
    _bookings.addAll([
      _bookingJson(
        id: 'fake-booking-seed-1',
        originName: 'Maison',
        destinationName: 'Aéroport Strasbourg-Entzheim',
        scheduledPickup: today.add(
          const Duration(days: 1, hours: 6, minutes: 15),
        ),
        offerName: 'Taxi',
        minPriceCents: 2700,
        maxPriceCents: 3300,
      ),
      _bookingJson(
        id: 'fake-booking-seed-2',
        originName: 'Travail',
        destinationName: 'Gare de Strasbourg',
        scheduledPickup: today.add(
          const Duration(days: 3, hours: 18, minutes: 30),
        ),
        offerName: 'Taxi Van',
        minPriceCents: 1400,
        maxPriceCents: 1700,
      ),
    ]);
  }

  final List<Map<String, dynamic>> _bookings = [];
  final List<Map<String, dynamic>> _pastRides = [];

  static const _rideId = 'fake-ride-id';
  static const _searchDuration = Duration(seconds: 3);
  static const _minuteDuration = Duration(seconds: 3);
  static const _initialEtaMinutes = 4;
  static const _rideSteps = 5;

  // The driver starts ~800 m away from the passenger.
  static const _startLatitudeOffset = 0.006;
  static const _startLongitudeOffset = -0.004;

  // Fake meter, same national caps as the fake taxi offers.
  static const _pickupFeeCents = 448;
  static const _pricePerKmCents = 130;
  static const _idleTimeCents = 150;

  double _originLatitude = 0;
  double _originLongitude = 0;
  double _destinationLatitude = 0;
  double _destinationLongitude = 0;
  String _destinationName = '';
  bool _isCancelled = false;

  @override
  Future<String> requestRide({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required int minPriceCents,
    required int maxPriceCents,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _originLatitude = originLatitude;
    _originLongitude = originLongitude;
    _destinationLatitude = destinationLatitude;
    _destinationLongitude = destinationLongitude;
    _destinationName = destinationName;
    _isCancelled = false;
    return _rideId;
  }

  @override
  Stream<RideModel> watchRide(String rideId) async* {
    yield RideModel.fromJson({'id': rideId, 'status': 'SEARCHING_DRIVER'});
    await Future<void>.delayed(_searchDuration);

    for (var eta = _initialEtaMinutes; eta >= 1; eta--) {
      if (_isCancelled) return;
      yield RideModel.fromJson(_driverApproachingJson(rideId, eta));
      await Future<void>.delayed(_minuteDuration);
    }

    for (var step = 0; step < _rideSteps; step++) {
      if (_isCancelled) return;
      yield RideModel.fromJson(_inProgressJson(rideId, step / _rideSteps));
      await Future<void>.delayed(_minuteDuration);
    }

    final completed = _completedJson(rideId);
    _pastRides.insert(
      0,
      _pastRideJson(
        'Ma position',
        _destinationName,
        DateTime.now(),
        'A',
        completed['totalCents'] as int,
      ),
    );
    yield RideModel.fromJson(completed);
  }

  @override
  Future<void> cancelRide(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _isCancelled = true;
  }

  @override
  Future<void> rateRide({
    required String rideId,
    required int stars,
    required List<String> compliments,
    required int tipCents,
  }) => Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<String> bookRide({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required String offerId,
    required String offerName,
    required int minPriceCents,
    required int maxPriceCents,
    required DateTime scheduledPickup,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final bookingId = 'fake-booking-${_bookings.length + 1}';
    _bookings.add(
      _bookingJson(
        id: bookingId,
        originName: 'Ma position',
        destinationName: destinationName,
        scheduledPickup: scheduledPickup,
        offerName: offerName,
        minPriceCents: minPriceCents,
        maxPriceCents: maxPriceCents,
      ),
    );
    return bookingId;
  }

  Map<String, dynamic> _bookingJson({
    required String id,
    required String originName,
    required String destinationName,
    required DateTime scheduledPickup,
    required String offerName,
    required int minPriceCents,
    required int maxPriceCents,
  }) => {
    'id': id,
    'originName': originName,
    'destinationName': destinationName,
    'scheduledPickup': scheduledPickup.toIso8601String(),
    'offerName': offerName,
    'minPriceCents': minPriceCents,
    'maxPriceCents': maxPriceCents,
  };

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _bookings.removeWhere((booking) => booking['id'] == bookingId);
  }

  @override
  Future<RideHistoryModel> getRideHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final upcoming = [..._bookings]
      ..sort(
        (a, b) => (a['scheduledPickup'] as String).compareTo(
          b['scheduledPickup'] as String,
        ),
      );
    return RideHistoryModel.fromJson({
      'upcoming': upcoming,
      'past': _pastRides,
    });
  }

  Map<String, dynamic> _pastRideJson(
    String originName,
    String destinationName,
    DateTime startedAt,
    String tariff,
    int totalCents,
  ) => {
    'id': 'fake-past-${startedAt.millisecondsSinceEpoch}',
    'originName': originName,
    'destinationName': destinationName,
    'startedAt': startedAt.toIso8601String(),
    'tariff': tariff,
    'totalCents': totalCents,
  };

  Map<String, dynamic> _driverApproachingJson(String rideId, int etaMinutes) {
    // Moves the driver towards the passenger as the ETA drops.
    final remainingShare = etaMinutes / _initialEtaMinutes;
    return {
      'id': rideId,
      'status': 'DRIVER_APPROACHING',
      'etaMinutes': etaMinutes,
      'boardingCode': '4817',
      'pickup': {'latitude': _originLatitude, 'longitude': _originLongitude},
      'driverPosition': {
        'latitude': _originLatitude + _startLatitudeOffset * remainingShare,
        'longitude': _originLongitude + _startLongitudeOffset * remainingShare,
      },
      ...simulatedDriverAndVehicleJson,
    };
  }

  Map<String, dynamic> _inProgressJson(String rideId, double doneShare) {
    final distanceKm = _straightLineKm();
    final rideMinutes = max(3, (distanceKm * 2).round());
    return {
      'id': rideId,
      'status': 'IN_PROGRESS',
      'taxiPosition': {
        'latitude':
            _originLatitude +
            (_destinationLatitude - _originLatitude) * doneShare,
        'longitude':
            _originLongitude +
            (_destinationLongitude - _originLongitude) * doneShare,
      },
      'destination': {
        'latitude': _destinationLatitude,
        'longitude': _destinationLongitude,
      },
      'meterCents':
          _pickupFeeCents + (_pricePerKmCents * distanceKm * doneShare).round(),
      'tariff': 'A',
      'remainingKm': distanceKm * (1 - doneShare),
      'estimatedArrival': DateTime.now()
          .add(Duration(minutes: (rideMinutes * (1 - doneShare)).round()))
          .toIso8601String(),
      ...simulatedDriverAndVehicleJson,
    };
  }

  Map<String, dynamic> _completedJson(String rideId) {
    final distanceKm = _straightLineKm();
    final distanceCents = (_pricePerKmCents * distanceKm).round();
    final kilometers = distanceKm.toStringAsFixed(1).replaceAll('.', ',');
    return {
      'id': rideId,
      'status': 'COMPLETED',
      'destinationName': _destinationName,
      'arrivedAt': DateTime.now().toIso8601String(),
      'totalCents': _pickupFeeCents + distanceCents + _idleTimeCents,
      'fareLines': [
        {'label': 'Prise en charge', 'amountCents': _pickupFeeCents},
        {'label': 'Distance, $kilometers km', 'amountCents': distanceCents},
        {'label': 'Temps de ralenti', 'amountCents': _idleTimeCents},
      ],
      ...simulatedDriverAndVehicleJson,
    };
  }

  // As the crow flies: good enough for fake data.
  double _straightLineKm() {
    const kmPerDegree = 111.0;
    final latitudeKm = (_destinationLatitude - _originLatitude) * kmPerDegree;
    final longitudeKm =
        (_destinationLongitude - _originLongitude) *
        kmPerDegree *
        cos(_originLatitude * pi / 180);
    return sqrt(latitudeKm * latitudeKm + longitudeKm * longitudeKm);
  }

  // Also used by the real ride source: the backend knows neither the vehicles
  // nor the drivers' ratings yet.
  static const Map<String, Map<String, Object>> simulatedDriverAndVehicleJson =
      {
        'driver': {
          'name': 'Luc S.',
          'rating': 4.9,
          'completedRides': 2340,
          'taxiNumber': '118',
          'city': 'Strasbourg',
        },
        'vehicle': {
          'model': 'Toyota Corolla Touring',
          'color': 'noire',
          'plate': 'GH-482-KZ',
          'department': '67',
        },
      };
}
