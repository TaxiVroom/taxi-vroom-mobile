import 'package:equatable/equatable.dart';

sealed class RegistrationDocument extends Equatable {
  const RegistrationDocument({required this.documentTypeId, this.lastValidDay});

  final String documentTypeId;

  // The last valid day typed by the driver, for a type that expires. Spec
  // taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 2.
  final DateTime? lastValidDay;
}

final class SubmittedRegistrationDocument extends RegistrationDocument {
  const SubmittedRegistrationDocument({
    required super.documentTypeId,
    super.lastValidDay,
  });

  @override
  List<Object?> get props => [documentTypeId, lastValidDay];
}

final class ValidatedRegistrationDocument extends RegistrationDocument {
  const ValidatedRegistrationDocument({
    required super.documentTypeId,
    super.lastValidDay,
  });

  @override
  List<Object?> get props => [documentTypeId, lastValidDay];
}

final class RejectedRegistrationDocument extends RegistrationDocument {
  const RejectedRegistrationDocument({
    required super.documentTypeId,
    required this.reason,
    super.lastValidDay,
  });

  final String reason;

  @override
  List<Object?> get props => [documentTypeId, reason, lastValidDay];
}
