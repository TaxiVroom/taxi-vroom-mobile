import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/features/driver_home/data/models/current_driver_ride_model.dart';
import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';
import 'package:mobile/features/driver_home/data/models/ride_start_model.dart';

abstract class DriverRideRemoteDataSource {
  // Null without a ride to come back to.
  Future<CurrentDriverRideModel?> getCurrentRide();

  Future<void> arriveAtPickup(String rideId);

  Future<RideStartModel> startRide({
    required String rideId,
    required String boardingCode,
  });

  Future<void> reportNoShow(String rideId);

  Future<void> withdrawFromRide(String rideId);

  // The ride's status, again at each change.
  Stream<String> watchRideStatus(String rideId);

  Future<void> completeRide({
    required String rideId,
    required int meterCents,
    required List<
      ({String supplementId, String label, int unitPriceCents, int quantity})
    >
    supplements,
  });
}

// The steps of the ride go through the API; the backend writes the ride at
// rides/<rideId>, readable by its driver.
// Docs: https://firebase.google.com/docs/database/flutter/read-and-write
class DriverRideRemoteDataSourceImpl implements DriverRideRemoteDataSource {
  const DriverRideRemoteDataSourceImpl(this._database, this._dio);

  final FirebaseDatabase _database;
  final Dio _dio;

  // The API tells the ride and its step; rides/<rideId> holds its details.
  @override
  Future<CurrentDriverRideModel?> getCurrentRide() async {
    final Map<String, dynamic> current;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/rides/current',
      );
      current = response.data!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    final rideId = current['id'] as String;
    final ride = await _database.ref('rides/$rideId').get();
    return CurrentDriverRideModel.fromJson(
      current,
      ride: DriverRideModel.fromSnapshot(rideId, ride),
    );
  }

  @override
  Future<void> arriveAtPickup(String rideId) =>
      _dio.post<void>('/v1/rides/$rideId/arrive');

  // A refused code comes back as a 422.
  @override
  Future<RideStartModel> startRide({
    required String rideId,
    required String boardingCode,
  }) async {
    await _dio.post<void>(
      '/v1/rides/$rideId/start',
      data: {'boardingCode': boardingCode},
    );
    return RideStartModel.accepted;
  }

  @override
  Future<void> reportNoShow(String rideId) =>
      _dio.post<void>('/v1/rides/$rideId/no-show');

  @override
  Future<void> withdrawFromRide(String rideId) =>
      _dio.post<void>('/v1/rides/$rideId/withdraw');

  @override
  Stream<String> watchRideStatus(String rideId) => _database
      .ref('rides/$rideId/status')
      .onValue
      .where((event) => event.snapshot.value != null)
      .map((event) => event.snapshot.value! as String);

  @override
  Future<void> completeRide({
    required String rideId,
    required int meterCents,
    required List<
      ({String supplementId, String label, int unitPriceCents, int quantity})
    >
    supplements,
  }) => _dio.post<void>(
    '/v1/rides/$rideId/complete',
    data: {
      'meterCents': meterCents,
      'supplements': [
        for (final supplement in supplements)
          {
            'supplementId': supplement.supplementId,
            'label': supplement.label,
            'unitPriceCents': supplement.unitPriceCents,
            'quantity': supplement.quantity,
          },
      ],
    },
  );
}
