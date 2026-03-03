import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

class GetOrCreateRegistrationFlowUseCase {
  const GetOrCreateRegistrationFlowUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegistrationFlowEntity> call({required String userId, required UserRole role, required String phone}) {
    return _repository.getOrCreateRegistrationFlow(userId: userId, role: role, phone: phone);
  }
}
