import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

// GET /v1/registration-flows/me, for a passenger or a driver: the
// repository maps it with toDomain().
abstract class RegistrationFlowModel {
  const RegistrationFlowModel();

  RegistrationFlowEntity toDomain();
}
