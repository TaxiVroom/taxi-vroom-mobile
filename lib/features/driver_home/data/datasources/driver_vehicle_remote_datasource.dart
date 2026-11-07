import 'package:dio/dio.dart';
import 'package:mobile/features/driver_home/data/models/driver_vehicle_model.dart';

abstract class DriverVehicleRemoteDataSource {
  // Null for a driver registered before the "Votre taxi" step existed.
  Future<DriverVehicleModel?> getVehicle();
}

// The vehicle given at the registration, copied when the driver was created.
class DriverVehicleRemoteDataSourceImpl
    implements DriverVehicleRemoteDataSource {
  const DriverVehicleRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DriverVehicleModel?> getVehicle() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/drivers/me/vehicle',
      );
      return DriverVehicleModel.fromJson(response.data!);
    } on DioException catch (e) {
      // 404: no vehicle yet, not a failure.
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
