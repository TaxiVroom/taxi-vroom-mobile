import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_checkout_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/ride_checkout_model.dart';
import 'package:mobile/features/driver_home/data/models/ride_start_model.dart';

/// Implémentation de développement : le code de montée de toutes les
/// courses est « 4817 ». Simule aussi les suppléments et la note du client,
/// qui n'ont pas encore de backend.
class DriverRideRemoteDataSourceFake
    implements DriverRideRemoteDataSource, RideCheckoutRemoteDataSource {
  static const _boardingCode = '4817';

  // Same rule as the server: locked after 5 wrong codes.
  static const _maxAttempts = 5;

  var _failedAttempts = 0;

  @override
  Future<void> arriveAtPickup(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<RideStartModel> startRide({
    required String rideId,
    required String boardingCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_failedAttempts >= _maxAttempts) {
      return RideStartModel.fromJson({'code': 'RIDE.BOARDING_CODE_LOCKED'});
    }
    if (boardingCode != _boardingCode) {
      _failedAttempts++;
      return RideStartModel.fromJson({
        'code': 'RIDE.WRONG_BOARDING_CODE',
        'attemptsLeft': _maxAttempts - _failedAttempts,
      });
    }
    return RideStartModel.accepted;
  }

  @override
  Future<void> reportNoShow(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> withdrawFromRide(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  // The passenger never cancels.
  @override
  Stream<String> watchRideStatus(String rideId) => const Stream.empty();

  // The supplement amounts are examples: the real ones depend on the city's
  // fare rules.
  @override
  Future<RideCheckoutModel> getCheckout(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return RideCheckoutModel.fromJson({
      'supplements': [
        {
          'id': 'bulky-luggage',
          'label': 'Bagage encombrant',
          'amountCents': 200,
        },
        {
          'id': 'fifth-passenger',
          'label': '5e passager et plus',
          'amountCents': 400,
        },
      ],
    });
  }

  @override
  Future<void> completeRide({
    required String rideId,
    required int meterCents,
    required List<
      ({String supplementId, String label, int unitPriceCents, int quantity})
    >
    supplements,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> rateCustomer({
    required String rideId,
    required int rating,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
