import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';

// The server: answers each start with what the test chose.
class _FakeDriverRideRepository implements DriverRideRepository {
  _FakeDriverRideRepository(this.answer);

  final RideStart answer;

  @override
  Future<Result<RideStart>> startRide({
    required String rideId,
    required String boardingCode,
  }) async => Result.ok(answer);

  @override
  Future<Result<CurrentDriverRide?>> getCurrentRide() =>
      throw UnimplementedError();

  @override
  Future<Result<void>> arriveAtPickup(String rideId) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> reportNoShow(String rideId) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> withdrawFromRide(String rideId) =>
      throw UnimplementedError();

  @override
  Stream<void> watchPassengerCancellation(String rideId) =>
      throw UnimplementedError();

  @override
  Future<Result<RideCheckout>> getCheckout(String rideId) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> completeRide({
    required String rideId,
    required int meterCents,
    required List<(FareSupplement, int)> supplements,
    required int customerRating,
  }) => throw UnimplementedError();
}

void main() {
  group('StartRideUseCase', () {
    Future<Result<RideStart>> startWith(RideStart answer) =>
        StartRideUseCase(_FakeDriverRideRepository(answer))(
          rideId: 'ride-id',
          boardingCode: '1234',
        );

    test('a wrong code with attempts left can be typed again', () async {
      // Arrange
      const answer = RideStartWrongCode(attemptsLeft: 1);

      // Act
      final result = await startWith(answer);

      // Assert
      expect(result, isA<Ok<RideStart>>());
      expect((result as Ok<RideStart>).value, answer);
    });

    test('the last wrong code locks the start at once', () async {
      // Arrange
      const answer = RideStartWrongCode(attemptsLeft: 0);

      // Act
      final result = await startWith(answer);

      // Assert
      expect((result as Ok<RideStart>).value, const RideStartLocked());
    });
  });
}
