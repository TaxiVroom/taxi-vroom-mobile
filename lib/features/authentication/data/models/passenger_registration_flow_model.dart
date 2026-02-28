import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

final class PassengerRegistrationFlowModel extends PassengerRegistrationFlowEntity {
  const PassengerRegistrationFlowModel({
    required super.userId,
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });

  factory PassengerRegistrationFlowModel.fromJson(Map<String, dynamic> json) {
    return PassengerRegistrationFlowModel(
      userId: json['firebase_uid'] as String,
      currentStep: PassengerRegistrationStep.values.byName(json['current_step'] as String),
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }
}
