import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class GetOrCreateRegistrationFlowUseCase {
  const GetOrCreateRegistrationFlowUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegistrationFlowEntity> call({required String userId}) {
    return _repository.getOrCreateRegistrationFlow(userId: userId);
  }
}
