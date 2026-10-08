import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource_fake.dart';
import 'package:mobile/features/passenger_home/data/models/ride_history_model.dart';
import 'package:mobile/features/passenger_home/data/models/ride_model.dart';
import 'package:stream_transform/stream_transform.dart';

abstract class RideRemoteDataSource {
  Future<String> requestRide({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required int minPriceCents,
    required int maxPriceCents,
  });

  Stream<RideModel> watchRide(String rideId);

  Future<void> cancelRide(String rideId);

  Future<void> rateRide({
    required String rideId,
    required int stars,
    required List<String> compliments,
    required int tipCents,
  });

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
  });

  Future<void> cancelBooking(String bookingId);

  Future<RideHistoryModel> getRideHistory();
}

// The ride is ordered through the API; the backend then writes it at
// rides/<rideId> as it goes. Once a driver accepted, their position comes
// from drivers/<uid> and the boarding code from rideBoardingCodes/<rideId>,
// readable by the passenger only.
// Docs: https://firebase.google.com/docs/database/flutter/read-and-write
class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  const RideRemoteDataSourceImpl(this._database, this._dio, this._simulated);

  final FirebaseDatabase _database;
  final Dio _dio;

  // Cancelling, rating, booking and the history have no backend yet.
  final RideRemoteDataSource _simulated;

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
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/rides',
      data: {
        'originLatitude': originLatitude,
        'originLongitude': originLongitude,
        'destinationName': destinationName,
        'destinationLatitude': destinationLatitude,
        'destinationLongitude': destinationLongitude,
        'estimatedPriceMinCents': minPriceCents,
        'estimatedPriceMaxCents': maxPriceCents,
      },
    );
    return response.data!['id'] as String;
  }

  @override
  Stream<RideModel> watchRide(String rideId) => _database
      .ref('rides/$rideId')
      .onValue
      .where((event) => event.snapshot.value != null)
      // A new status replaces what the previous one listened to.
      .switchMap((event) => _rideModels(rideId, event.snapshot));

  Stream<RideModel> _rideModels(String rideId, DataSnapshot ride) {
    final status = ride.child('status').value! as String;
    return switch (status) {
      'SEARCHING_DRIVER' || 'NO_DRIVER_FOUND' => Stream.value(
        RideModel.fromJson({'id': rideId, 'status': status}),
      ),
      'DRIVER_EN_ROUTE' => _approachingModels(rideId, ride),
      _ => Stream.error(FormatException('Statut de course inconnu : $status')),
    };
  }

  // Again at each move of the driver.
  Stream<RideModel> _approachingModels(String rideId, DataSnapshot ride) {
    final driverId = ride.child('driverId').value! as String;
    final positions = _database
        .ref('drivers/$driverId')
        .onValue
        // Gone when the driver loses the connection: the last one stays.
        .where((event) => event.snapshot.value != null)
        .map((event) => event.snapshot);
    final boardingCodes = _database
        .ref('rideBoardingCodes/$rideId/code')
        .onValue
        .where((event) => event.snapshot.value != null)
        .map((event) => event.snapshot.value! as String);
    return positions.combineLatest(
      boardingCodes,
      (position, boardingCode) => RideModel.fromJson(
        _approachingJson(rideId, ride, position, boardingCode),
      ),
    );
  }

  Map<String, dynamic> _approachingJson(
    String rideId,
    DataSnapshot ride,
    DataSnapshot position,
    String boardingCode,
  ) {
    const simulated = RideRemoteDataSourceFake.simulatedDriverAndVehicleJson;
    final driver = ride.child('driver');
    final lastName = driver.child('lastName').value! as String;
    return {
      'id': rideId,
      'status': 'DRIVER_APPROACHING',
      'boardingCode': boardingCode,
      'pickup': _coordinates(ride.child('pickup')),
      'driverPosition': _coordinates(position),
      'driver': {
        ...simulated['driver']!,
        'name': '${driver.child('firstName').value} ${lastName[0]}.',
      },
      'vehicle': simulated['vehicle'],
    };
  }

  Map<String, num> _coordinates(DataSnapshot place) => {
    'latitude': place.child('latitude').value! as num,
    'longitude': place.child('longitude').value! as num,
  };

  @override
  Future<void> cancelRide(String rideId) => _simulated.cancelRide(rideId);

  @override
  Future<void> rateRide({
    required String rideId,
    required int stars,
    required List<String> compliments,
    required int tipCents,
  }) => _simulated.rateRide(
    rideId: rideId,
    stars: stars,
    compliments: compliments,
    tipCents: tipCents,
  );

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
  }) => _simulated.bookRide(
    originLatitude: originLatitude,
    originLongitude: originLongitude,
    destinationLatitude: destinationLatitude,
    destinationLongitude: destinationLongitude,
    destinationName: destinationName,
    offerId: offerId,
    offerName: offerName,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    scheduledPickup: scheduledPickup,
  );

  @override
  Future<void> cancelBooking(String bookingId) =>
      _simulated.cancelBooking(bookingId);

  @override
  Future<RideHistoryModel> getRideHistory() => _simulated.getRideHistory();
}
