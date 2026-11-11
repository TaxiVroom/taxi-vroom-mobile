import 'package:dio/dio.dart';
import 'package:mobile/features/driver_home/data/models/driver_activity_model.dart';

abstract class DriverActivityRemoteDataSource {
  Future<DriverActivityModel> getActivity();
}

// The pill and the three cards of the "Conduire" tab in one call. Spec
// taxi-vroom-api/docs/specs/gains-reels.md.
class DriverActivityRemoteDataSourceImpl
    implements DriverActivityRemoteDataSource {
  const DriverActivityRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DriverActivityModel> getActivity() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/drivers/me/activity',
    );
    return DriverActivityModel.fromJson(response.data!);
  }
}
