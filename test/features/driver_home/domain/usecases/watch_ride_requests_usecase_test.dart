import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request_update.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_ride_requests_usecase.dart';

// The server: offers and takes back the requests the test sends.
class _FakeRideRequestRepository implements RideRequestRepository {
  final requests = StreamController<Result<RideRequest?>>();

  @override
  Stream<Result<RideRequest?>> watchRideRequests({
    required Coordinates around,
  }) => requests.stream;

  @override
  Future<Result<DriverRide>> acceptRideRequest(String requestId) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> declineRideRequest(String requestId) =>
      throw UnimplementedError();
}

// Mapbox, unreachable: the requests come without their roads.
class _FakeRouteRepository implements RouteRepository {
  @override
  Future<Result<RideRoute>> getRoute({
    required Coordinates from,
    required Coordinates to,
    DateTime? arriveBy,
  }) async => const Result.error(NetworkFailure('Connexion impossible'));

  @override
  Future<Result<NavigationRoute>> getNavigationRoute({
    required Coordinates from,
    required Coordinates to,
  }) => throw UnimplementedError();
}

void main() {
  group('WatchRideRequestsUseCase', () {
    const driverPosition = Coordinates(latitude: 48.57, longitude: 7.75);

    RideRequest requestSent(DateTime sentAt) => RideRequest(
      id: 'request',
      sentAt: sentAt,
      minPriceCents: 2700,
      maxPriceCents: 3300,
      distanceKm: 14.8,
      pickupName: 'Place Broglie',
      pickup: const Coordinates(latitude: 48.58, longitude: 7.75),
      destinationName: 'Aéroport Strasbourg-Entzheim',
      destination: const Coordinates(latitude: 48.54, longitude: 7.63),
      customerFirstName: 'Camille',
      customerRating: 4.8,
      passengerCount: 1,
      luggageCount: 1,
    );

    late _FakeRideRequestRepository requests;
    late Stream<Result<RideRequestUpdate>> updates;

    setUp(() {
      requests = _FakeRideRequestRepository();
      updates = WatchRideRequestsUseCase(
        rideRequestRepository: requests,
        routeRepository: _FakeRouteRepository(),
      )(driverPosition: driverPosition);
    });

    tearDown(() => requests.requests.close());

    test('a request taken back in time was cancelled by the passenger', () {
      // Arrange
      final request = requestSent(DateTime.now());

      // Act
      requests.requests
        ..add(Result.ok(request))
        ..add(const Result.ok(null));

      // Assert
      expect(
        updates.map((result) => (result as Ok<RideRequestUpdate>).value),
        emitsInOrder([
          isA<IncomingRideRequest>(),
          const CancelledRideRequest(requestId: 'request'),
        ]),
      );
    });

    test('a request taken back once its time ran out says nothing', () {
      // Arrange
      final request = requestSent(
        DateTime.now().subtract(const Duration(seconds: 16)),
      );

      // Act
      requests.requests
        ..add(Result.ok(request))
        ..add(const Result.ok(null));
      unawaited(requests.requests.close());

      // Assert
      expect(
        updates.map((result) => (result as Ok<RideRequestUpdate>).value),
        emitsInOrder([isA<IncomingRideRequest>(), emitsDone]),
      );
    });

    test('no request waiting when going online says nothing', () {
      // Arrange
      const nothingOffered = Result<RideRequest?>.ok(null);

      // Act
      requests.requests.add(nothingOffered);
      unawaited(requests.requests.close());

      // Assert
      expect(updates, emitsDone);
    });
  });
}
