import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/domain/usecases/message_phone_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

// The phone, which opens a link in another app, or cannot.
class _FakePhone implements NavigationRepository {
  _FakePhone({this.opens = true});

  final bool opens;
  final List<Uri> opened = [];

  @override
  Future<Result<void>> open(Uri link) async {
    opened.add(link);
    return opens
        ? const Result.ok(null)
        : const Result.error(DeviceFailure('not opened'));
  }
}

void main() {
  group('MessagePhoneUseCase', () {
    test('opens the messages app on a new message to the number', () async {
      // Arrange
      final phone = _FakePhone();

      // Act
      final result = await MessagePhoneUseCase(phone)('+33612345678');

      // Assert
      expect(result, isA<Ok<void>>());
      expect(phone.opened, [Uri.parse('sms:+33612345678')]);
    });

    test('the phone cannot open the link: told', () async {
      // Arrange
      final phone = _FakePhone(opens: false);

      // Act
      final result = await MessagePhoneUseCase(phone)('+33612345678');

      // Assert
      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).error.message,
        'Impossible d’ouvrir les messages.',
      );
    });
  });
}
