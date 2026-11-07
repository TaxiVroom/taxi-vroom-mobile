import 'package:mobile/features/authentication/data/models/registration_flow_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

final class PassengerRegistrationFlowModel extends RegistrationFlowModel {
  const PassengerRegistrationFlowModel({
    required this.userId,
    required this.currentStep,
    this.email,
    this.firstName,
    this.lastName,
  });

  factory PassengerRegistrationFlowModel.fromJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    return PassengerRegistrationFlowModel(
      userId: userId,
      currentStep: _parseStep(json['currentStep'] as String),
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  final String userId;
  final PassengerRegistrationStep currentStep;
  final String? email;
  final String? firstName;
  final String? lastName;

  @override
  PassengerRegistrationFlowEntity toDomain() => PassengerRegistrationFlowEntity(
    userId: userId,
    currentStep: currentStep,
    email: email,
    firstName: firstName,
    lastName: lastName,
  );

  // Backend uses UPPER_SNAKE_CASE values.
  static PassengerRegistrationStep _parseStep(String value) => switch (value) {
    'SOCIAL_LINK' => PassengerRegistrationStep.socialLink,
    'EMAIL' => PassengerRegistrationStep.email,
    'NAME' => PassengerRegistrationStep.name,
    'NOTIFICATIONS' => PassengerRegistrationStep.notifications,
    'COMPLETE' => PassengerRegistrationStep.complete,
    _ => throw UnimplementedError('Unknown registration step: $value'),
  };
}
