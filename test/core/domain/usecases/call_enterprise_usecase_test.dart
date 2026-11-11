import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/repositories/enterprise_contact_repository.dart';
import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/domain/usecases/call_enterprise_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

// The API, which gives the number, or fails.
class _FakeApi implements EnterpriseContactRepository {
  _FakeApi(this.answer);

  final Result<String> answer;
  int asked = 0;

  @override
  Future<Result<String>> getPhone() async {
    asked++;
    return answer;
  }
}

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
  group('CallEnterpriseUseCase', () {
    test('opens the phone app on the number the API gives', () async {
      // Arrange
      final api = _FakeApi(const Result.ok('+33612345678'));
      final phone = _FakePhone();

      // Act
      final result = await CallEnterpriseUseCase(
        enterpriseContactRepository: api,
        navigationRepository: phone,
      )();

      // Assert
      expect(result, isA<Ok<void>>());
      expect(phone.opened, [Uri.parse('tel:+33612345678')]);
    });

    test(
      'a number already received opens at once, the API not asked',
      () async {
        // Arrange: the driver's "Compte" tab got it when it opened.
        final api = _FakeApi(const Result.ok('+33600000000'));
        final phone = _FakePhone();

        // Act
        final result = await CallEnterpriseUseCase(
          enterpriseContactRepository: api,
          navigationRepository: phone,
        )(knownPhone: '+33612345678');

        // Assert
        expect(result, isA<Ok<void>>());
        expect(phone.opened, [Uri.parse('tel:+33612345678')]);
        expect(api.asked, 0);
      },
    );

    test('no number from the API: told, nothing opened', () async {
      // Arrange
      final api = _FakeApi(const Result.error(NetworkFailure('offline')));
      final phone = _FakePhone();

      // Act
      final result = await CallEnterpriseUseCase(
        enterpriseContactRepository: api,
        navigationRepository: phone,
      )();

      // Assert
      expect(
        (result as Error<void>).error.message,
        'Impossible d’ouvrir le téléphone.',
      );
      expect(phone.opened, isEmpty);
    });

    test('no phone app, e.g. a tablet: told the same', () async {
      // Arrange
      final api = _FakeApi(const Result.ok('+33612345678'));
      final phone = _FakePhone(opens: false);

      // Act
      final result = await CallEnterpriseUseCase(
        enterpriseContactRepository: api,
        navigationRepository: phone,
      )();

      // Assert
      expect(
        (result as Error<void>).error.message,
        'Impossible d’ouvrir le téléphone.',
      );
    });
  });
}
