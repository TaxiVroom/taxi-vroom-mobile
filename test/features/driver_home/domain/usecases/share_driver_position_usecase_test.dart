import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';

// The GPS: gives the positions the test sends.
class _FakeLocationRepository implements LocationRepository {
  final positions = StreamController<Result<Coordinates>>();

  @override
  Future<Result<Coordinates>> getCurrentPosition() =>
      throw UnimplementedError();

  @override
  Stream<Result<Coordinates>> watchPosition({bool inBackground = false}) =>
      positions.stream;

  @override
  Future<void> openSettings() => throw UnimplementedError();
}

// The database: keeps the positions written.
class _FakeDriverPresenceRepository implements DriverPresenceRepository {
  final written = <Coordinates>[];

  @override
  Future<Result<void>> updatePosition(Coordinates position) async {
    written.add(position);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> goOnline(Coordinates position) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> goOffline() => throw UnimplementedError();

  @override
  Stream<bool> watchOnlineAllowed() => throw UnimplementedError();
}

void main() {
  group('ShareDriverPositionUseCase', () {
    const a = Coordinates(latitude: 48.5734, longitude: 7.7521);
    const b = Coordinates(latitude: 48.5740, longitude: 7.7530);
    const c = Coordinates(latitude: 48.5746, longitude: 7.7539);

    test('writes at most one position every 3 seconds, the latest one', () {
      fakeAsync((time) {
        // Arrange
        final location = _FakeLocationRepository();
        final presence = _FakeDriverPresenceRepository();
        final useCase = ShareDriverPositionUseCase(
          locationRepository: location,
          driverPresenceRepository: presence,
        );
        useCase().listen((_) {});

        // Act
        location.positions.add(const Result.ok(a));
        time.elapse(const Duration(seconds: 1));
        location.positions.add(const Result.ok(b));
        time.elapse(const Duration(seconds: 1));
        location.positions.add(const Result.ok(c));
        time.elapse(const Duration(milliseconds: 999));
        final writtenJustBefore3Seconds = [...presence.written];
        time.elapse(const Duration(milliseconds: 1));

        // Assert
        expect(writtenJustBefore3Seconds, [a]);
        expect(presence.written, [a, c]);
      });
    });

    // 0.0001 degree of latitude is about 11.1 meters.
    const parked = Coordinates(latitude: 48.5734, longitude: 7.7521);
    const moved9Meters90 = Coordinates(latitude: 48.573489, longitude: 7.7521);
    const moved10Meters10 = Coordinates(
      latitude: 48.5734908,
      longitude: 7.7521,
    );

    test('does not write a move under 10 meters', () {
      fakeAsync((time) {
        // Arrange
        final location = _FakeLocationRepository();
        final presence = _FakeDriverPresenceRepository();
        final useCase = ShareDriverPositionUseCase(
          locationRepository: location,
          driverPresenceRepository: presence,
        );
        useCase().listen((_) {});

        // Act
        location.positions.add(const Result.ok(parked));
        time.elapse(const Duration(seconds: 3));
        location.positions.add(const Result.ok(moved9Meters90));
        time.elapse(const Duration(seconds: 3));

        // Assert
        expect(presence.written, [parked]);
      });
    });

    test('writes a move of 10 meters or more', () {
      fakeAsync((time) {
        // Arrange
        final location = _FakeLocationRepository();
        final presence = _FakeDriverPresenceRepository();
        final useCase = ShareDriverPositionUseCase(
          locationRepository: location,
          driverPresenceRepository: presence,
        );
        useCase().listen((_) {});

        // Act
        location.positions.add(const Result.ok(parked));
        time.elapse(const Duration(seconds: 3));
        location.positions.add(const Result.ok(moved10Meters10));
        time.elapse(const Duration(seconds: 3));

        // Assert
        expect(presence.written, [parked, moved10Meters10]);
      });
    });

    test('shares a slow drift once it reaches 10 meters', () {
      fakeAsync((time) {
        // Arrange
        final location = _FakeLocationRepository();
        final presence = _FakeDriverPresenceRepository();
        final useCase = ShareDriverPositionUseCase(
          locationRepository: location,
          driverPresenceRepository: presence,
        );
        useCase().listen((_) {});

        // Act: a slow drift, under 10 meters each time, but over 10 in all.
        location.positions.add(const Result.ok(parked));
        time.elapse(const Duration(seconds: 3));
        location.positions.add(
          const Result.ok(Coordinates(latitude: 48.573445, longitude: 7.7521)),
        );
        time.elapse(const Duration(seconds: 3));
        location.positions.add(const Result.ok(moved10Meters10));
        time.elapse(const Duration(seconds: 3));

        // Assert
        expect(presence.written, [parked, moved10Meters10]);
      });
    });
  });
}
