import 'dart:math';

import 'package:mobile/core/data/models/paged_list_model.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_booking_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/booked_ride_model.dart';
import 'package:mobile/features/passenger_home/data/models/past_ride_model.dart';
import 'package:mobile/features/passenger_home/data/models/ride_model.dart';
import 'package:mobile/features/passenger_home/data/models/simulated_driver_and_vehicle_json.dart';
import 'package:mobile/features/passenger_home/data/models/taxi_offer_model.dart';

/// Implémentation de développement avec données de test.
/// Simule une course complète : estimation, recherche, chauffeur qui approche
/// puis attend, trajet, puis fin de course. Une « minute » dure 3 s.
/// Garde aussi en mémoire les réservations et l'historique des courses.
class RideRemoteDataSourceFake
    implements
        TaxiOfferRemoteDataSource,
        RideRemoteDataSource,
        RideBookingRemoteDataSource {
  RideRemoteDataSourceFake() {
    final now = DateTime.now();
    _pastRides.addAll([
      _pastRideJson(
        'Gare',
        'Maison',
        now.subtract(const Duration(days: 2)),
        1120,
      ),
      _pastRideJson(
        'Maison',
        'Travail',
        now.subtract(const Duration(days: 5)),
        2190,
      ),
      _pastRideJson(
        'Rivétoile',
        'Maison',
        now.subtract(const Duration(days: 15)),
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
        minPriceCents: 2700,
        maxPriceCents: 3300,
        driverFirstName: 'Jean',
      ),
      _bookingJson(
        id: 'fake-booking-seed-2',
        originName: 'Travail',
        destinationName: 'Gare de Strasbourg',
        scheduledPickup: today.add(
          const Duration(days: 3, hours: 18, minutes: 30),
        ),
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

  // Fake prices and meter from the national caps.
  static const _pickupFeeCents = 448;
  static const _pricePerKmCents = 130;
  static const _minimumFareCents = 800;
  static const _idleTimeCents = 150;

  // Shown in "Comment est calculé le prix ?": the Bas-Rhin 2026 arrêté.
  static const Map<String, Object> _tariffJson = {
    'departmentCode': '67',
    'validFrom': '2026-02-01',
    'decree': 'Arrêté préfectoral du 26 janvier 2026',
    'pickupCents': 310,
    'kmCentsA': 101,
    'kmCentsB': 143,
    'kmCentsC': 202,
    'kmCentsD': 286,
    'hourlyCents': 3780,
    'minimumFareCents': 800,
    'nightStartMinute': 19 * 60,
    'nightEndMinute': 7 * 60,
  };

  double _originLatitude = 0;
  double _originLongitude = 0;
  double _destinationLatitude = 0;
  double _destinationLongitude = 0;
  String _destinationName = '';
  int _minPriceCents = 0;
  int _maxPriceCents = 0;
  bool _isCancelled = false;

  // Of the latest estimate, to book it.
  DateTime? _scheduledPickup;

  // One taxi priced from the national caps, with a ±10 % range.
  @override
  Future<List<TaxiOfferModel>> getOffers({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required String destinationName,
    required int passengerCount,
    String? fromName,
    DateTime? scheduledPickup,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _scheduledPickup = scheduledPickup;
    _originLatitude = fromLatitude;
    _originLongitude = fromLongitude;
    _destinationLatitude = toLatitude;
    _destinationLongitude = toLongitude;
    _destinationName = destinationName;
    final fareCents =
        _pickupFeeCents + (_pricePerKmCents * _straightLineKm()).round();
    _minPriceCents = max((fareCents * 0.9).round(), _minimumFareCents);
    _maxPriceCents = max((fareCents * 1.1).round(), _minimumFareCents);
    return [
      TaxiOfferModel.fromJson({
        'id': 'taxi',
        'rideId': _rideId,
        'name': 'Taxi',
        'description': '4 places',
        'pickupEtaMinutes': _initialEtaMinutes,
        'minPriceCents': _minPriceCents,
        'maxPriceCents': _maxPriceCents,
        'priceNote': 'hors suppléments',
        'tariff': _tariffJson,
      }),
    ];
  }

  @override
  Future<void> requestRide(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _isCancelled = false;
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

    if (_isCancelled) return;
    yield RideModel.fromJson(_driverArrivedJson(rideId));
    await Future<void>.delayed(_minuteDuration);

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
  }) => Future<void>.delayed(const Duration(milliseconds: 400));

  // Books the latest estimate, like the backend.
  @override
  Future<void> bookRide(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _bookings.add(
      _bookingJson(
        id: 'fake-booking-${_bookings.length + 1}',
        originName: 'Ma position',
        destinationName: _destinationName,
        scheduledPickup: _scheduledPickup ?? DateTime.now(),
        minPriceCents: _minPriceCents,
        maxPriceCents: _maxPriceCents,
      ),
    );
  }

  // The JSON of GET /v1/rides/booked.
  Map<String, dynamic> _bookingJson({
    required String id,
    required String originName,
    required String destinationName,
    required DateTime scheduledPickup,
    required int minPriceCents,
    required int maxPriceCents,
    String? driverFirstName,
  }) => {
    'id': id,
    'originName': originName,
    'destinationName': destinationName,
    'pickupAt': scheduledPickup.toUtc().toIso8601String(),
    'estimatedPriceMinCents': minPriceCents,
    'estimatedPriceMaxCents': maxPriceCents,
    'driverFirstName': driverFirstName,
  };

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _bookings.removeWhere((booking) => booking['id'] == bookingId);
  }

  @override
  Future<PagedListModel<BookedRideModel>> getBookings({
    required int page,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final upcoming = [..._bookings]
      ..sort(
        (a, b) => (a['pickupAt'] as String).compareTo(
          b['pickupAt'] as String,
        ),
      );
    return PagedListModel.pageOf(
      upcoming.map(BookedRideModel.fromJson).toList(),
      page: page,
    );
  }

  @override
  Future<String?> getCurrentRideId() async => null;

  @override
  Future<PagedListModel<PastRideModel>> getPastRides({
    required int page,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return PagedListModel.pageOf(
      _pastRides.map(PastRideModel.fromJson).toList(),
      page: page,
    );
  }

  Map<String, dynamic> _pastRideJson(
    String originName,
    String destinationName,
    DateTime startedAt,
    int totalCents,
  ) => {
    'id': 'fake-past-${startedAt.millisecondsSinceEpoch}',
    'originName': originName,
    'destinationName': destinationName,
    'startedAt': startedAt.toIso8601String(),
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

  Map<String, dynamic> _driverArrivedJson(String rideId) => {
    'id': rideId,
    'status': 'DRIVER_ARRIVED',
    'boardingCode': '4817',
    'driverPosition': {
      'latitude': _originLatitude,
      'longitude': _originLongitude,
    },
    ...simulatedDriverAndVehicleJson,
  };

  Map<String, dynamic> _inProgressJson(String rideId, double doneShare) {
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
      'estimatedPriceMinCents': _minPriceCents,
      'estimatedPriceMaxCents': _maxPriceCents,
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
}
