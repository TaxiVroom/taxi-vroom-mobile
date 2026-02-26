import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class CreatePassengerUseCase {
  const CreatePassengerUseCase(this._repository);

  final AuthRepository _repository;

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
