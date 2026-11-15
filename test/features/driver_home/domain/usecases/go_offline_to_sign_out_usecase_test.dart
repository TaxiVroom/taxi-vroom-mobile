import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/connection_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/go_offline_to_sign_out_usecase.dart';

// Whether the phone reaches Firebase right now.
class _FakeConnectionRepository implements ConnectionRepository {
  _FakeConnectionRepository({required this.isConnected});

  final bool isConnected;

  @override
  Stream<bool> watchConnection() => Stream.value(isConnected);
}

// The driver's entry, removed for good or not.
class _FakeDriverPresenceRepository extends Fake
    implements DriverPresenceRepository {
  _FakeDriverPresenceRepository({this.removal = const Result.ok(null)});

  final Result<void> removal;
  bool removed = false;

  @override
  Future<Result<void>> goOfflineConfirmed() async {
    removed = true;
    return removal;
  }

  @override
  Future<Result<void>> goOnline(Coordinates position) async =>
      const Result.ok(null);
}

void main() {
  group('GoOfflineToSignOutUseCase', () {
    test('connected: the entry is removed, sign-out may go on', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository();
      final useCase = GoOfflineToSignOutUseCase(
        connectionRepository: _FakeConnectionRepository(isConnected: true),
        driverPresenceRepository: presence,
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Ok<void>>());
      expect(presence.removed, isTrue);
    });

    test('no network: refused, the entry is left untouched', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository();
      final useCase = GoOfflineToSignOutUseCase(
        connectionRepository: _FakeConnectionRepository(isConnected: false),
        driverPresenceRepository: presence,
      );

      // Act
      final result = await useCase();

      // Assert
      expect((result as Error<void>).error, isA<NetworkFailure>());
      expect(presence.removed, isFalse);
    });

    test('the removal fails: refused, so the driver stays online', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(
        removal: const Result.error(NetworkFailure('Pas de connexion')),
      );
      final useCase = GoOfflineToSignOutUseCase(
        connectionRepository: _FakeConnectionRepository(isConnected: true),
        driverPresenceRepository: presence,
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Error<void>>());
    });
  });
}
