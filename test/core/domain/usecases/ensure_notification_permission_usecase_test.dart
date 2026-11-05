import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

// The phone: its current permission, and its answer when asked.
class _FakePhone implements NotificationPermissionRepository {
  _FakePhone({required this.status, this.answer});

  final Result<NotificationPermission> status;
  final Result<NotificationPermission>? answer;
  int requests = 0;

  @override
  Future<Result<NotificationPermission>> getStatus() async => status;

  @override
  Future<Result<NotificationPermission>> request() async {
    requests++;
    return answer!;
  }

  @override
  Future<Result<void>> openSettings() => throw UnimplementedError();
}

const _failure = PermissionFailure('Permission inconnue.');

void main() {
  group('EnsureNotificationPermissionUseCase', () {
    test('asks nothing when notifications are already allowed', () async {
      // Arrange
      final phone = _FakePhone(
        status: const Result.ok(NotificationPermission.granted),
      );

      // Act
      final result = await EnsureNotificationPermissionUseCase(phone)();

      // Assert
      expect(phone.requests, 0);
      expect(result, isA<Ok<NotificationPermission>>());
      expect(
        (result as Ok<NotificationPermission>).value,
        NotificationPermission.granted,
      );
    });

    test('asks the phone when notifications are not allowed', () async {
      // Arrange
      final phone = _FakePhone(
        status: const Result.ok(NotificationPermission.denied),
        answer: const Result.ok(NotificationPermission.granted),
      );

      // Act
      final result = await EnsureNotificationPermissionUseCase(phone)();

      // Assert
      expect(phone.requests, 1);
      expect(
        (result as Ok<NotificationPermission>).value,
        NotificationPermission.granted,
      );
    });

    test('tells when only the settings can allow them now', () async {
      // Arrange: Android answers at once, without a dialog.
      final phone = _FakePhone(
        status: const Result.ok(NotificationPermission.denied),
        answer: const Result.ok(NotificationPermission.permanentlyDenied),
      );

      // Act
      final result = await EnsureNotificationPermissionUseCase(phone)();

      // Assert
      expect(
        (result as Ok<NotificationPermission>).value,
        NotificationPermission.permanentlyDenied,
      );
    });

    test('asks nothing when the permission cannot be read', () async {
      // Arrange
      final phone = _FakePhone(status: const Result.error(_failure));

      // Act
      final result = await EnsureNotificationPermissionUseCase(phone)();

      // Assert
      expect(phone.requests, 0);
      expect(result, isA<Error<NotificationPermission>>());
    });
  });
}
