import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';
import 'package:mobile/features/driver_home/data/models/ride_request_model.dart';

abstract class RideRequestRemoteDataSource {
  // Null when no request waits for the driver: none came, or the one offered
  // was taken back.
  Stream<RideRequestModel?> watchRideRequests({
    required double latitude,
    required double longitude,
  });

  Future<DriverRideModel> acceptRideRequest(String requestId);

  Future<void> declineRideRequest(String requestId);
}

// The backend chooses the driver and writes the ride proposed to them at
// rideOffers/<uid>; the answer goes back through the API. A request's id is
// its ride's id.
// Docs: https://firebase.google.com/docs/database/flutter/read-and-write
class RideRequestRemoteDataSourceImpl implements RideRequestRemoteDataSource {
  const RideRequestRemoteDataSourceImpl(
    this._database,
    this._firebaseAuth,
    this._dio,
  );

  final FirebaseDatabase _database;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  // Unknown to the backend yet.
  static const _customerRating = 5.0;
  static const _passengerCount = 1;
  static const _luggageCount = 0;

  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'firebase_database',
        code: 'unauthenticated',
        message: 'Connectez-vous pour recevoir des courses.',
      );
    }
    return uid;
  }

  // The driver's position is not needed: the backend already chose them.
  // Removed by the backend once answered, expired, or cancelled by the
  // passenger.
  @override
  Stream<RideRequestModel?> watchRideRequests({
    required double latitude,
    required double longitude,
  }) => _database
      .ref('rideOffers/$_uid')
      .onValue
      .map(
        (event) => event.snapshot.value == null
            ? null
            : RideRequestModel.fromJson(_requestJson(event.snapshot)),
      );

  @override
  Future<DriverRideModel> acceptRideRequest(String requestId) async {
    await _dio.post<void>('/v1/rides/$requestId/accept');
    // Readable by the driver once the ride is theirs.
    final ride = await _database.ref('rides/$requestId').get();
    return DriverRideModel.fromSnapshot(requestId, ride);
  }

  @override
  Future<void> declineRideRequest(String requestId) =>
      _dio.post<void>('/v1/rides/$requestId/decline');

  Map<String, dynamic> _requestJson(DataSnapshot offer) {
    final pickup = DriverRideModel.placeJson(offer.child('pickup'));
    final destination = DriverRideModel.placeJson(offer.child('destination'));
    // Only written for a booking that starts.
    final pickupAt = offer.child('pickupAt').value as int?;
    return {
      'id': offer.child('rideId').value! as String,
      'sentAt': DateTime.fromMillisecondsSinceEpoch(
        offer.child('offeredAt').value! as int,
      ).toIso8601String(),
      'minPriceCents': offer.child('estimatedPriceMinCents').value! as int,
      'maxPriceCents': offer.child('estimatedPriceMaxCents').value! as int,
      // As the crow flies: the road distance comes with the route.
      'distanceKm':
          _coordinates(pickup).distanceTo(_coordinates(destination)) / 1000,
      'pickup': pickup,
      'destination': destination,
      'customer': {
        'firstName': offer.child('passengerFirstName').value! as String,
        'rating': _customerRating,
      },
      'passengerCount': _passengerCount,
      'luggageCount': _luggageCount,
      'scheduledPickup': pickupAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(pickupAt).toIso8601String(),
    };
  }

  Coordinates _coordinates(Map<String, dynamic> place) => Coordinates(
    latitude: (place['latitude'] as num).toDouble(),
    longitude: (place['longitude'] as num).toDouble(),
  );
}
