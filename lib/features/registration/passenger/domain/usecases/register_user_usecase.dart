import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';

class RegisterUserUseCase {
  const RegisterUserUseCase(this._repository);

  final RegistrationRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) {
    return _repository.registerWithEmail(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }
}
