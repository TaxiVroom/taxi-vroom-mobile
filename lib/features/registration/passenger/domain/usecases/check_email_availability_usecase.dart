import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';

class CheckEmailAvailabilityUseCase {
  const CheckEmailAvailabilityUseCase(this._repository);

  final RegistrationRepository _repository;

  Future<bool> call({required String email}) =>
      _repository.checkEmailAvailability(email: email);
}
