import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';

void main() {
  group('DriverRideStep.fromStatus', () {
    test('a driver coming goes back to the drive to the pickup', () {
      // Act
      final step = DriverRideStep.fromStatus('DRIVER_EN_ROUTE');

      // Assert
      expect(step, DriverRideStep.pickup);
    });

    test('a driver at the pickup goes back to the boarding code', () {
      // Act
      final step = DriverRideStep.fromStatus('DRIVER_ARRIVED');

      // Assert
      expect(step, DriverRideStep.boarding);
    });

    test('a ride in progress goes back to the drive to the destination', () {
      // Act
      final step = DriverRideStep.fromStatus('IN_PROGRESS');

      // Assert
      expect(step, DriverRideStep.inRide);
    });

    test("any other status is not the driver's to come back to", () {
      // Act
      final step = DriverRideStep.fromStatus('SEARCHING_DRIVER');

      // Assert
      expect(step, isNull);
    });
  });
}
