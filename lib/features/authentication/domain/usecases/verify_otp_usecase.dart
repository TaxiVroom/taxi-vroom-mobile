import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String phoneNumber,
    required String otp,
  }) {
    return _repository.verifyOtp(phoneNumber: phoneNumber, otp: otp);
  }
}
