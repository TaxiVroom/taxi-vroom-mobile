import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/passenger_account_model.dart';

abstract class AccountRemoteDataSource {
  Future<PassengerAccountModel> getAccount();
}

// The passenger's profile, from GET /v1/me, read again each time the
// "Compte" tab opens. Spec taxi-vroom-api/docs/specs/compte-a-jour.md.
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  const AccountRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PassengerAccountModel> getAccount() async {
    final response = await _dio.get<Map<String, dynamic>>('/v1/me');
    return PassengerAccountModel.fromJson(response.data!);
  }
}
