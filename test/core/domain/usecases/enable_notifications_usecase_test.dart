import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/domain/usecases/enable_notifications_usecase.dart';
import 'package:mobile/core/utils/result.dart';

// The phone: its permission, its answer when asked, and its settings page.
class _FakePhone implements NotificationPermissionRepository {
  _FakePhone({required this.status, this.answer});

  final NotificationPermission status;
  final NotificationPermission? answer;
  int settingsOpened = 0;

  @override
  Future<Result<NotificationPermission>> getStatus() async => Result.ok(status);

  @override
  Future<Result<NotificationPermission>> request() async => Result.ok(answer!);

  @override
  Future<Result<void>> openSettings() async {
    settingsOpened++;
    return const Result.ok(null);
  }
}

void main() {
  group('EnableNotificationsUseCase', () {
    test('the dialog allowed them: no settings', () async {
      // Arrange
      final phone = _FakePhone(
        status: NotificationPermission.denied,
        answer: NotificationPermission.granted,
      );

      // Act
      final result = await EnableNotificationsUseCase(phone)();

      // Assert
      expect(
        (result as Ok<NotificationPermission>).value,
        NotificationPermission.granted,
      );
      expect(phone.settingsOpened, 0);
    });

    test('blocked: the phone settings open, the person asked for it', () async {
      // Arrange: Android answers at once, without a dialog.
      final phone = _FakePhone(
        status: NotificationPermission.denied,
        answer: NotificationPermission.permanentlyDenied,
      );

      // Act
      await EnableNotificationsUseCase(phone)();

      // Assert
      expect(phone.settingsOpened, 1);
    });

    test('already allowed: nothing opens', () async {
      // Arrange
      final phone = _FakePhone(status: NotificationPermission.granted);

      // Act
      await EnableNotificationsUseCase(phone)();

      // Assert
      expect(phone.settingsOpened, 0);
    });
  });

  group('NotificationPermission needsSettings', () {
    test('only a permanent denial needs the settings', () {
      // Assert
      expect(
        NotificationPermission.values.where((p) => p.needsSettings),
        [NotificationPermission.permanentlyDenied],
      );
    });
  });
}
