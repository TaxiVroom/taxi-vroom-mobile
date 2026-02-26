import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<void> sendOtp({required String phoneNumber}) =>
      _dataSource.sendOtp(phoneNumber: phoneNumber);

  @override
  Future<UserEntity> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) =>
      _dataSource.verifyOtp(phoneNumber: phoneNumber, otp: otp);

  @override
  Future<UserEntity> linkGoogleAccount() => _dataSource.linkGoogleAccount();

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
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({required String userId}) =>
      _dataSource.getOrCreateRegistrationFlow(userId: userId);

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
