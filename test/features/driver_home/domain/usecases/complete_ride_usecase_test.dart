import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/complete_ride_usecase.dart';

// The server: keeps the meter amount and the supplements it receives.
class _FakeDriverRideRepository implements DriverRideRepository {
  int? sentMeterCents;
  List<(FareSupplement, int)>? sentSupplements;

  @override
  Future<Result<void>> completeRide({
    required String rideId,
    required int meterCents,
    required List<(FareSupplement, int)> supplements,
    required int customerRating,
  }) async {
    sentMeterCents = meterCents;
    sentSupplements = supplements;
    return const Result.ok(null);
  }

  @override
  Future<Result<CurrentDriverRide?>> getCurrentRide() =>
      throw UnimplementedError();

  @override
  Future<Result<void>> arriveAtPickup(String rideId) =>
      throw UnimplementedError();

  @override
  Future<Result<RideStart>> startRide({
    required String rideId,
    required String boardingCode,
  }) => throw UnimplementedError();

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
}

void main() {
  group('CompleteRideUseCase', () {
    const bulkyLuggage = FareSupplement(
      id: 'bulky-luggage',
      label: 'Bagage encombrant',
      amountCents: 200,
    );
    const checkout = RideCheckout(
      supplements: [bulkyLuggage],
    );

    test('refuses to end the ride before the meter amount is typed', () async {
      // Arrange
      final server = _FakeDriverRideRepository();

      // Act
      final result = await CompleteRideUseCase(server)(
        rideId: 'ride-id',
        checkout: checkout,
        customerRating: 0,
      );

      // Assert
      expect((result as Error<void>).error, isA<ValidationFailure>());
      expect(server.sentMeterCents, isNull);
    });

    test('sends the typed meter amount and the supplements added', () async {
      // Arrange
      final server = _FakeDriverRideRepository();
      final typed = checkout.withMeterCents(1840).withCount(bulkyLuggage, 2);

      // Act
      final result = await CompleteRideUseCase(server)(
        rideId: 'ride-id',
        checkout: typed,
        customerRating: 5,
      );

      // Assert
      expect(result, isA<Ok<void>>());
      expect(server.sentMeterCents, 1840);
      expect(server.sentSupplements, [(bulkyLuggage, 2)]);
    });
  });
}
