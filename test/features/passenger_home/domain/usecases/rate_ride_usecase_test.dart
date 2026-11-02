import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_compliment.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';

// The server: counts the ratings it receives, or refuses them.
class _FakeRideRepository implements RideRepository {
  _FakeRideRepository({this.failure});

  final Failure? failure;
  int receivedRatings = 0;

  @override
  Future<Result<void>> rateRide({
    required String rideId,
    required int stars,
    required List<RideCompliment> compliments,
  }) async {
    receivedRatings++;
    final failure = this.failure;
    return failure == null ? const Result.ok(null) : Result.error(failure);
  }

  @override
  Future<Result<String>> requestRide(TaxiOffer offer) =>
      throw UnimplementedError();

  @override
  Future<Result<String?>> getCurrentRideId() => throw UnimplementedError();

  @override
  Stream<Result<Ride>> watchRide(String rideId) => throw UnimplementedError();

  @override
  Future<Result<void>> cancelRide(String rideId) => throw UnimplementedError();

  @override
  Future<Result<String>> bookRide({
    required Coordinates origin,
    required Place destination,
    required TaxiOffer offer,
    required DateTime scheduledPickup,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> cancelBooking(String bookingId) =>
      throw UnimplementedError();

  @override
  Future<Result<RideHistory>> getRideHistory() => throw UnimplementedError();
}

void main() {
  group('RateRideUseCase', () {
    test('sends the rating of a passenger who gave stars', () async {
      // Arrange
      final server = _FakeRideRepository();

      // Act
      await RateRideUseCase(server)(
        rideId: 'ride-id',
        stars: 5,
        compliments: const [RideCompliment.punctual],
      );

      // Assert
      expect(server.receivedRatings, 1);
    });

    test('sends nothing when the passenger gave no star', () async {
      // Arrange
      final server = _FakeRideRepository();

      // Act
      final result = await RateRideUseCase(server)(
        rideId: 'ride-id',
        stars: 0,
        compliments: const [RideCompliment.punctual],
      );

      // Assert
      expect(server.receivedRatings, 0);
      expect(result, isA<Ok<void>>());
    });

    test('tells when the rating failed to send', () async {
      // Arrange
      final server = _FakeRideRepository(
        failure: const NetworkFailure('Connexion impossible'),
      );

      // Act
      final result = await RateRideUseCase(server)(
        rideId: 'ride-id',
        stars: 5,
        compliments: const [],
      );

      // Assert
      expect(result, isA<Error<void>>());
    });
  });
}
