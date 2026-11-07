import 'package:mobile/features/authentication/data/models/registration_flow_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/data/models/registration_vehicle_model.dart';

final class DriverRegistrationFlowModel extends RegistrationFlowModel {
  const DriverRegistrationFlowModel({
    required this.userId,
    required this.currentStep,
    this.email,
    this.firstName,
    this.lastName,
    this.vehicle,
  });

  factory DriverRegistrationFlowModel.fromJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    return DriverRegistrationFlowModel(
      userId: userId,
      currentStep: _parseStep(json['currentStep'] as String),
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      vehicle: vehicle == null
          ? null
          : RegistrationVehicleModel.fromJson(vehicle),
    );
  }

  final String userId;
  final DriverRegistrationStep currentStep;
  final String? email;
  final String? firstName;
  final String? lastName;
  final RegistrationVehicleModel? vehicle;

  @override
  DriverRegistrationFlowEntity toDomain() => DriverRegistrationFlowEntity(
    userId: userId,
    currentStep: currentStep,
    email: email,
    firstName: firstName,
    lastName: lastName,
    vehicle: vehicle?.toDomain(),
  );

  // Backend uses UPPER_SNAKE_CASE values. NOTIFICATIONS is a mobile-only UI
  // step: if the user resumes from that point, we show the notifications
  // screen (complete).
  static DriverRegistrationStep _parseStep(String value) => switch (value) {
    'SOCIAL_LINK' => DriverRegistrationStep.socialLink,
    'EMAIL' => DriverRegistrationStep.email,
    'NAME' => DriverRegistrationStep.name,
    'VEHICLE' => DriverRegistrationStep.vehicle,
    'DOCUMENTS' => DriverRegistrationStep.documents,
    'PENDING_REVIEW' => DriverRegistrationStep.pendingReview,
    'DOCUMENTS_CORRECTION' => DriverRegistrationStep.documentsCorrection,
    'NOTIFICATIONS' => DriverRegistrationStep.complete,
    'COMPLETE' => DriverRegistrationStep.complete,
    _ => throw UnimplementedError('Unknown registration step: $value'),
  };
}
