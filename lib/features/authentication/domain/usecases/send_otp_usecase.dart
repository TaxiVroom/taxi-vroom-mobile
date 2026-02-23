import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String phoneNumber}) {
    return _repository.sendOtp(phoneNumber: phoneNumber);
  }
}
