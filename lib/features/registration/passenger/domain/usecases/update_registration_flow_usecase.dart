import 'package:mobile/features/registration/passenger/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/registration/passenger/domain/repositories/registration_repository.dart';

class UpdateRegistrationFlowUseCase {
  const UpdateRegistrationFlowUseCase(this._repository);

  final RegistrationRepository _repository;

  Future<void> call({
    required String userId,
    required RegistrationFlowUpdate update,
  }) {
    return _repository.updateRegistrationFlow(userId: userId, update: update);
  }
}
