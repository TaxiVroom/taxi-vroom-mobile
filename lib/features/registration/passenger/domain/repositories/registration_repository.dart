import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/registration/shared/domain/repositories/registration_flow_repository.dart';

abstract class RegistrationRepository implements RegistrationFlowRepository {
  Future<UserEntity> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  Future<Result<void>> completeRegistration();
}
