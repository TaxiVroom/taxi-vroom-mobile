import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/phone_formatter.dart';

void main() {
  group('formatPhone', () {
    test('spaces a French number as it is read aloud', () {
      // Arrange
      const phone = '+33700000007';

      // Act
      final formatted = formatPhone(phone);

      // Assert
      expect(formatted, '+33 7 00 00 00 07');
    });

    test('leaves a foreign number as it is', () {
      // Arrange
      const phone = '+4915123456789';

      // Act
      final formatted = formatPhone(phone);

      // Assert
      expect(formatted, '+4915123456789');
    });
  });
}
