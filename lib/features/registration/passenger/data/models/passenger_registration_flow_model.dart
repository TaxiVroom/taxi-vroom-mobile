import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

final class PassengerRegistrationFlowModel extends PassengerRegistrationFlowEntity {
  const PassengerRegistrationFlowModel({
    required super.userId,
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
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

  // Backend uses UPPER_SNAKE_CASE values.
  static PassengerRegistrationStep _parseStep(String value) => switch (value) {
        'SOCIAL_LINK'   => PassengerRegistrationStep.socialLink,
        'EMAIL'         => PassengerRegistrationStep.email,
        'NAME'          => PassengerRegistrationStep.name,
        'NOTIFICATIONS' => PassengerRegistrationStep.notifications,
        'COMPLETE'      => PassengerRegistrationStep.complete,
        _               => throw UnimplementedError('Unknown registration step: $value'),
      };
}
