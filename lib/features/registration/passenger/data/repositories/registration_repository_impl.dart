import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/registration/passenger/data/datasources/registration_remote_datasource.dart';
import 'package:mobile/features/registration/passenger/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';

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
  Future<bool> checkEmailAvailability({required String email}) =>
      _dataSource.checkEmailAvailability(email: email);

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      _dataSource.updateRegistrationFlow(userId: userId, update: update);

  @override
  Future<void> createPassenger({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) =>
      _dataSource.createPassenger(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
}
