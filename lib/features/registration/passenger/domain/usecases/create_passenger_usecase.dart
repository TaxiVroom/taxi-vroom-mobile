import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';

class CreatePassengerUseCase {
  const CreatePassengerUseCase(this._repository);

  final RegistrationRepository _repository;

  Future<void> call({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) {
    return _repository.createPassenger(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
