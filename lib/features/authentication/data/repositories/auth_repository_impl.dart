import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
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
  }) => _dataSource.verifyOtp(phoneNumber: phoneNumber, otp: otp);

  @override
  Future<UserEntity> linkGoogleAccount() => _dataSource.linkGoogleAccount();

  @override
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({
    required String userId,
    required UserRole role,
    required String phone,
  }) => _dataSource.getOrCreateRegistrationFlow(
    userId: userId,
    role: role,
    phone: phone,
  );

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(ServerFailure(e.message ?? 'Déconnexion impossible'));
    }
  }
}
