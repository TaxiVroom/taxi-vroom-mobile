import 'package:mobile/features/authentication/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class UpdateRegistrationFlowUseCase {
  const UpdateRegistrationFlowUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String userId,
    required RegistrationFlowUpdate update,
  }) {
    return _repository.updateRegistrationFlow(userId: userId, update: update);
  }
}
