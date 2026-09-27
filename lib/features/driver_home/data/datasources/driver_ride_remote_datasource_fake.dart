import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/ride_checkout_model.dart';

/// Implémentation de développement : le code de montée de toutes les
/// courses est « 4817 », et les courses sont payées par l'application.
class DriverRideRemoteDataSourceFake implements DriverRideRemoteDataSource {
  static const _boardingCode = '4817';

  @override
  Future<bool> verifyBoardingCode({
    required String rideId,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return code == _boardingCode;
  }

  @override
  Future<void> startRide(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> reportNoShow(String rideId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

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
      'payment': {'paidInApp': true, 'label': 'Visa de Camille'},
    });
  }

  @override
  Future<void> completeRide({
    required String rideId,
    required int meterCents,
    required Map<String, int> supplementCounts,
    required int totalCents,
    required int customerRating,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
