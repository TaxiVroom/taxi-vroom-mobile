import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';

void main() {
  group('RegistrationVehicle', () {
    group('formatPlate', () {
      test('typed without dashes, in lowercase: as on the plate', () {
        // Act
        final plate = RegistrationVehicle.formatPlate('ab123cd');

        // Assert
        expect(plate, 'AB-123-CD');
      });

      test('typed with spaces: as on the plate', () {
        // Act
        final plate = RegistrationVehicle.formatPlate(' AB 123 CD ');

        // Assert
        expect(plate, 'AB-123-CD');
      });

      test('an old plate "123 ABC 67": refused', () {
        // Act
        final plate = RegistrationVehicle.formatPlate('123 ABC 67');

        // Assert
        expect(plate, isNull);
      });

      test('incomplete: refused', () {
        // Act
        final plate = RegistrationVehicle.formatPlate('AB-12');

        // Assert
        expect(plate, isNull);
      });
    });
  });
}
