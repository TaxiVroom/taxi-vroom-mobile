import 'package:dio/dio.dart';
import 'package:mobile/features/driver_home/data/models/driver_account_model.dart';

abstract class DriverAccountRemoteDataSource {
  Future<DriverAccountModel> getAccount();
}

// The "Compte" tab in one call. Spec
// taxi-vroom-api/docs/specs/compte-a-jour.md.
class DriverAccountRemoteDataSourceImpl
    implements DriverAccountRemoteDataSource {
  const DriverAccountRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DriverAccountModel> getAccount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/drivers/me/account',
    );
    return DriverAccountModel.fromJson(response.data!);
  }
}
