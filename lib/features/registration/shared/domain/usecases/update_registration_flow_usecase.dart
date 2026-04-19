import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/registration/shared/domain/repositories/registration_flow_repository.dart';

class UpdateRegistrationFlowUseCase {
  const UpdateRegistrationFlowUseCase(this._repository);

  final RegistrationFlowRepository _repository;

  Future<void> call({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      _repository.updateRegistrationFlow(userId: userId, update: update);
}
