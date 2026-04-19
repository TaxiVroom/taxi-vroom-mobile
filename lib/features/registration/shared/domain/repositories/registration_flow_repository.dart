import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

abstract class RegistrationFlowRepository {
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  });
}
