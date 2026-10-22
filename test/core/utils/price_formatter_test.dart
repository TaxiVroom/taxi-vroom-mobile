import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/price_formatter.dart';

void main() {
  group('formatEuroRange', () {
    test('widens the range to whole euros, never narrows it', () {
      // Arrange
      const minCents = 1260;
      const maxCents = 1740;

      // Act
      final range = formatEuroRange(minCents, maxCents);

      // Assert
      expect(range, '12–18 €');
    });

    test('keeps whole euros as they are', () {
      // Arrange
      const minCents = 2700;
      const maxCents = 3300;

      // Act
      final range = formatEuroRange(minCents, maxCents);

      // Assert
      expect(range, '27–33 €');
    });
  });

  group('parseEuroCents', () {
    test('reads a French amount with a comma', () {
      // Arrange
      const input = '29,67';

      // Act
      final cents = parseEuroCents(input);

      // Assert
      expect(cents, 2967);
    });

    test('reads a dot as the decimal separator too', () {
      // Arrange
      const input = '29.67';

      // Act
      final cents = parseEuroCents(input);

      // Assert
      expect(cents, 2967);
    });

    test('reads whole euros and one decimal', () {
      // Arrange
      const inputs = ['29', '29,5'];

      // Act
      final cents = inputs.map(parseEuroCents).toList();

      // Assert
      expect(cents, [2900, 2950]);
    });

    test('rejects what is not an amount', () {
      // Arrange
      const inputs = ['', 'abc', '29,678', '-3', '29 €'];

      // Act
      final cents = inputs.map(parseEuroCents).toList();

      // Assert
      expect(cents, everyElement(isNull));
    });
  });
}
