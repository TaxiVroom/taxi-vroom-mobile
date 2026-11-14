import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/passenger_home/data/models/ride_model.dart';

Map<String, dynamic> _json(String status, {bool? isDriverConnected}) => {
  'id': 'ride-1',
  'status': status,
  'boardingCode': '6297',
  'pickup': {'latitude': 48.5, 'longitude': 7.7},
  'driverPosition': {'latitude': 48.6, 'longitude': 7.8},
  'taxiPosition': {'latitude': 48.6, 'longitude': 7.8},
  'destination': {'latitude': 48.7, 'longitude': 7.9},
  'estimatedPriceMinCents': 1500,
  'estimatedPriceMaxCents': 2000,
  'driver': {
    'name': 'Luc S.',
    'phone': '+33700000001',
    'rating': 4.9,
    'completedRides': 12,
  },
  'vehicle': null,
  'isDriverConnected': ?isDriverConnected,
};

void main() {
  group("RideModel, the driver's connection", () {
    for (final status in [
      'DRIVER_APPROACHING',
      'DRIVER_ARRIVED',
      'IN_PROGRESS',
    ]) {
      test('$status: a driver who lost the connection is told', () {
        // Arrange
        final json = _json(status, isDriverConnected: false);

        // Act
        final ride = RideModel.fromJson(json).toDomain();

        // Assert
        expect(ride.isDriverConnected, isFalse);
      });

      test('$status: the driver is connected unless told otherwise', () {
        // Arrange
        final json = _json(status);

        // Act
        final ride = RideModel.fromJson(json).toDomain();

        // Assert
        expect(ride.isDriverConnected, isTrue);
      });
    }

    test('a ride without a driver yet has nothing to warn about', () {
      // Arrange
      final json = {'id': 'ride-1', 'status': 'SEARCHING_DRIVER'};

      // Act
      final ride = RideModel.fromJson(json).toDomain();

      // Assert
      expect(ride.isDriverConnected, isTrue);
    });
  });
}
