import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

final class DriverRegistrationFlowModel extends DriverRegistrationFlowEntity {
  const DriverRegistrationFlowModel({
    required super.userId,
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });

  factory DriverRegistrationFlowModel.fromJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    return DriverRegistrationFlowModel(
      userId: userId,
      currentStep: _parseStep(json['currentStep'] as String),
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  // Backend uses UPPER_SNAKE_CASE values. NOTIFICATIONS is a mobile-only UI step —
  // if the user resumes from that point, we show the notifications screen (complete).
  static DriverRegistrationStep _parseStep(String value) => switch (value) {
        'SOCIAL_LINK'           => DriverRegistrationStep.socialLink,
        'EMAIL'                 => DriverRegistrationStep.email,
        'NAME'                  => DriverRegistrationStep.name,
        'DOCUMENTS'             => DriverRegistrationStep.documents,
        'PENDING_REVIEW'        => DriverRegistrationStep.pendingReview,
        'DOCUMENTS_CORRECTION'  => DriverRegistrationStep.documentsCorrection,
        'NOTIFICATIONS'         => DriverRegistrationStep.complete,
        'COMPLETE'              => DriverRegistrationStep.complete,
        _                       => throw UnimplementedError('Unknown registration step: $value'),
      };
}
