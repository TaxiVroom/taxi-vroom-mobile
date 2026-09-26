import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/registration/passenger/data/datasources/registration_remote_datasource.dart';
import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  const RegistrationRepositoryImpl(this._dataSource);

  final RegistrationRemoteDataSource _dataSource;

  @override
  Future<UserEntity> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) =>
      _dataSource.registerWithEmail(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      _dataSource.updateRegistrationFlow(userId: userId, update: update);

  @override
  Future<Result<void>> completeRegistration() async {
    try {
      await _dataSource.completeRegistration();
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}
