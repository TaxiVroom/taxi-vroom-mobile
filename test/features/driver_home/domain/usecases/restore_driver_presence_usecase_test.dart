import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/restore_driver_presence_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';

const _here = Coordinates(latitude: 48.6067, longitude: 7.7362);

// The API's answer to "a ride in progress?".
class _FakeDriverRideRepository extends Fake implements DriverRideRepository {
  _FakeDriverRideRepository(this.current);

  final Result<CurrentDriverRide?> current;

  @override
  Future<Result<CurrentDriverRide?>> getCurrentRide() async => current;
}

// The driver's entry in Firebase: there or not, unreadable, and what was
// done to it.
class _FakeDriverPresenceRepository extends Fake
    implements DriverPresenceRepository {
  _FakeDriverPresenceRepository(this.presence);

  final Result<bool> presence;
  bool wentOnline = false;
  bool removed = false;

  @override
  Future<Result<bool>> hasPresence() async => presence;

  @override
  Future<Result<void>> goOnline(Coordinates position) async {
    wentOnline = true;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> goOffline() async {
    removed = true;
    return const Result.ok(null);
  }
}

class _FakeDriverDocumentRepository extends Fake
    implements DriverDocumentRepository {
  _FakeDriverDocumentRepository(this.allowed);

  final Result<void> allowed;

  @override
  Future<Result<void>> allowOnline() async => allowed;
}

class _FakeLocationRepository extends Fake implements LocationRepository {
  _FakeLocationRepository(this.position);

  final Result<Coordinates> position;

  @override
  Future<Result<Coordinates>> getCurrentPosition() async => position;
}

RestoreDriverPresenceUseCase _useCase({
  required _FakeDriverPresenceRepository presence,
  Result<CurrentDriverRide?> current = const Result.ok(null),
  Result<void> allowed = const Result.ok(null),
  Result<Coordinates> position = const Result.ok(_here),
}) => RestoreDriverPresenceUseCase(
  driverRideRepository: _FakeDriverRideRepository(current),
  driverPresenceRepository: presence,
  setOnlineUseCase: SetOnlineUseCase(
    locationRepository: _FakeLocationRepository(position),
    driverPresenceRepository: presence,
    driverDocumentRepository: _FakeDriverDocumentRepository(allowed),
  ),
);

void main() {
  group('RestoreDriverPresenceUseCase', () {
    test('a ride in progress: left to the ride, nothing touched', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(true));
      const ride = CurrentRideAtPickup(
        ride: DriverRide(
          id: 'ride-1',
          customerFirstName: 'Test',
          customerLastName: 'Client',
          customerPhone: '+33700000000',
          pickupName: '2 Rue Sébastien Brant',
          pickup: _here,
          destinationName: 'Gare',
          destination: _here,
        ),
      );
      final useCase = _useCase(
        presence: presence,
        current: const Result.ok(ride),
      );

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect(result, isA<Ok<bool>>());
      expect((result as Ok<bool>).value, isFalse);
      expect(presence.wentOnline, isFalse);
      expect(presence.removed, isFalse);
    });

    test('no ride, the entry is there: back online', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(true));
      final useCase = _useCase(presence: presence);

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect((result as Ok<bool>).value, isTrue);
      expect(presence.wentOnline, isTrue);
      expect(presence.removed, isFalse);
    });

    test('no ride, no entry: offline, nothing to tell', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(false));
      final useCase = _useCase(presence: presence);

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect((result as Ok<bool>).value, isFalse);
      expect(presence.wentOnline, isFalse);
    });

    test('the ride cannot be checked: entry removed, the reason', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(true));
      final useCase = _useCase(
        presence: presence,
        current: const Result.error(NetworkFailure('Pas de connexion')),
      );

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect(result, isA<Error<bool>>());
      expect(presence.wentOnline, isFalse);
      expect(presence.removed, isTrue);
    });

    test('a document blocks: entry removed, the documents reason', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(true));
      final useCase = _useCase(
        presence: presence,
        allowed: const Result.error(DocumentsBlockingFailure('Expiré')),
      );

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect(
        (result as Error<bool>).error,
        isA<DocumentsBlockingFailure>(),
      );
      expect(presence.wentOnline, isFalse);
      expect(presence.removed, isTrue);
    });

    test('no position: entry removed, the position reason', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(true));
      final useCase = _useCase(
        presence: presence,
        position: const Result.error(LocationFailure('Position introuvable')),
      );

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect((result as Error<bool>).error, isA<LocationFailure>());
      expect(presence.removed, isTrue);
    });

    test('the entry cannot be read: entry removed, the reason', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(
        const Result.error(NetworkFailure('Pas de connexion')),
      );
      final useCase = _useCase(presence: presence);

      // Act
      final result = await useCase(mayGoOnline: true);

      // Assert
      expect(result, isA<Error<bool>>());
      expect(presence.wentOnline, isFalse);
      expect(presence.removed, isTrue);
    });

    test('the home could not load: entry removed, never online', () async {
      // Arrange
      final presence = _FakeDriverPresenceRepository(const Result.ok(true));
      final useCase = _useCase(presence: presence);

      // Act
      final result = await useCase(mayGoOnline: false);

      // Assert
      expect((result as Ok<bool>).value, isFalse);
      expect(presence.wentOnline, isFalse);
      expect(presence.removed, isTrue);
    });
  });
}
