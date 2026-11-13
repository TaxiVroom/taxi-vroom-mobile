import 'package:dio/dio.dart';
import 'package:mobile/features/driver_home/data/models/ride_checkout_model.dart';

// The end of ride screen. The "5e passager et plus" line comes from the API
// (the ride's passengers and the tariff's price); the passenger's rating is
// not built and still simulated.
abstract class RideCheckoutRemoteDataSource {
  Future<RideCheckoutModel> getCheckout(String rideId);

  // [rating] is 0 when not rated.
  Future<void> rateCustomer({required String rideId, required int rating});
}

// GET /v1/rides/:rideId/checkout: the ride's passengers and the tariff's
// supplement for each one from the fifth, which make the only supplement line.
// Spec taxi-vroom-api/docs/specs/nombre-de-passagers.md, situation 6.
class RideCheckoutRemoteDataSourceImpl implements RideCheckoutRemoteDataSource {
  const RideCheckoutRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<RideCheckoutModel> getCheckout(String rideId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/rides/$rideId/checkout',
    );
    return RideCheckoutModel.fromJson({
      ...response.data!,
      'supplements': <Map<String, Object>>[],
    });
  }

  // No backend yet: simulated.
  @override
  Future<void> rateCustomer({
    required String rideId,
    required int rating,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
