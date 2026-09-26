import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';

class CompletePassengerRegistrationUseCase {
  const CompletePassengerRegistrationUseCase(this._repository);

  final RegistrationRepository _repository;

  Future<Result<void>> call() => _repository.completeRegistration();
}
