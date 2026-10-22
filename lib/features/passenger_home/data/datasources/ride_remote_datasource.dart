import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/features/passenger_home/data/models/ride_model.dart';
import 'package:mobile/features/passenger_home/data/models/simulated_driver_and_vehicle_json.dart';
import 'package:stream_transform/stream_transform.dart';

abstract class RideRemoteDataSource {
  // Orders the ride the backend estimated, at the price shown.
  Future<void> requestRide(String rideId);

  Stream<RideModel> watchRide(String rideId);

  Future<void> cancelRide(String rideId);
}

// The ride is estimated, then ordered through the API; the backend then
// writes it at
// rides/<rideId> as it goes. Once a driver accepted, their position comes
// from drivers/<uid>, and the boarding code from the API, which gives it to
// the passenger only.
// Docs: https://firebase.google.com/docs/database/flutter/read-and-write
class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  const RideRemoteDataSourceImpl(this._database, this._dio);

  final FirebaseDatabase _database;
  final Dio _dio;

  @override
  Future<void> requestRide(String rideId) =>
      _dio.post<void>('/v1/rides/$rideId/request');

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
      'SEARCHING_DRIVER' || 'NO_DRIVER_FOUND' || 'PASSENGER_NO_SHOW' =>
        Stream.value(RideModel.fromJson({'id': rideId, 'status': status})),
      'DRIVER_EN_ROUTE' => _withBoardingCode(
        rideId,
        ride,
        (position, boardingCode) => {
          'status': 'DRIVER_APPROACHING',
          'boardingCode': boardingCode,
          'pickup': _coordinates(ride.child('pickup')),
          'driverPosition': _coordinates(position),
        },
      ),
      'DRIVER_ARRIVED' => _withBoardingCode(
        rideId,
        ride,
        (position, boardingCode) => {
          'status': 'DRIVER_ARRIVED',
          'boardingCode': boardingCode,
          'driverPosition': _coordinates(position),
        },
      ),
      'IN_PROGRESS' => _driverPositions(ride).map(
        (position) => RideModel.fromJson(
          _withDriverJson(rideId, ride, {
            'status': 'IN_PROGRESS',
            'taxiPosition': _coordinates(position),
            'destination': _coordinates(ride.child('destination')),
            'estimatedPriceMinCents': ride
                .child('estimatedPriceMinCents')
                .value,
            'estimatedPriceMaxCents': ride
                .child('estimatedPriceMaxCents')
                .value,
          }),
        ),
      ),
      'COMPLETED' => Stream.value(
        RideModel.fromJson(_withDriverJson(rideId, ride, _completedJson(ride))),
      ),
      // Only the passenger cancels: their screen already left the ride.
      'CANCELLED' => const Stream.empty(),
      _ => Stream.error(FormatException('Statut de course inconnu : $status')),
    };
  }

  // The receipt the backend wrote at the end of the ride: the meter, then
  // each supplement.
  Map<String, dynamic> _completedJson(DataSnapshot ride) {
    final completion = ride.child('completion');
    return {
      'status': 'COMPLETED',
      'destinationName': ride.child('destination/name').value! as String,
      'arrivedAt': DateTime.fromMillisecondsSinceEpoch(
        completion.child('completedAt').value! as int,
      ).toIso8601String(),
      'totalCents': completion.child('totalCents').value! as int,
      'fareLines': [
        {
          'label': 'Compteur',
          'amountCents': completion.child('meterCents').value! as int,
        },
        for (final supplement in completion.child('supplements').children)
          _supplementLine(supplement),
      ],
    };
  }

  Map<String, dynamic> _supplementLine(DataSnapshot supplement) {
    final label = supplement.child('label').value! as String;
    final quantity = supplement.child('quantity').value! as int;
    final unitPriceCents = supplement.child('unitPriceCents').value! as int;
    return {
      'label': quantity > 1 ? '$label × $quantity' : label,
      'amountCents': unitPriceCents * quantity,
    };
  }

  // Again at each move of the driver. The code is asked once to the API: it
  // never goes through Firebase.
  Stream<RideModel> _withBoardingCode(
    String rideId,
    DataSnapshot ride,
    Map<String, dynamic> Function(DataSnapshot position, String boardingCode)
    json,
  ) => _driverPositions(ride).combineLatest(
    Stream.fromFuture(_boardingCode(rideId)),
    (position, boardingCode) => RideModel.fromJson(
      _withDriverJson(rideId, ride, json(position, boardingCode)),
    ),
  );

  Future<String> _boardingCode(String rideId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/rides/$rideId/boarding-code',
    );
    return response.data!['code'] as String;
  }

  Stream<DataSnapshot> _driverPositions(DataSnapshot ride) {
    final driverId = ride.child('driverId').value! as String;
    return _database
        .ref('drivers/$driverId')
        .onValue
        // Gone when the driver loses the connection: the last one stays.
        .where((event) => event.snapshot.value != null)
        .map((event) => event.snapshot);
  }

  Map<String, dynamic> _withDriverJson(
    String rideId,
    DataSnapshot ride,
    Map<String, dynamic> json,
  ) {
    final driver = ride.child('driver');
    final lastName = driver.child('lastName').value! as String;
    return {
      'id': rideId,
      ...json,
      'driver': {
        ...simulatedDriverAndVehicleJson['driver']!,
        'name': '${driver.child('firstName').value} ${lastName[0]}.',
      },
      'vehicle': simulatedDriverAndVehicleJson['vehicle'],
    };
  }

  Map<String, num> _coordinates(DataSnapshot place) => {
    'latitude': place.child('latitude').value! as num,
    'longitude': place.child('longitude').value! as num,
  };

  @override
  Future<void> cancelRide(String rideId) =>
      _dio.post<void>('/v1/rides/$rideId/cancel');
}
