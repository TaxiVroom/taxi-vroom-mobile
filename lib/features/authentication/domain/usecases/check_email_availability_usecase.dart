import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class CheckEmailAvailabilityUseCase {
  const CheckEmailAvailabilityUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call({required String email}) =>
      _repository.checkEmailAvailability(email: email);
}
