import 'package:equatable/equatable.dart';

sealed class RegistrationDocument extends Equatable {
  const RegistrationDocument({required this.documentTypeId});

  final String documentTypeId;
}

final class SubmittedRegistrationDocument extends RegistrationDocument {
  const SubmittedRegistrationDocument({required super.documentTypeId});

  @override
  List<Object?> get props => [documentTypeId];
}

final class ValidatedRegistrationDocument extends RegistrationDocument {
  const ValidatedRegistrationDocument({required super.documentTypeId});

  @override
  List<Object?> get props => [documentTypeId];
}

final class RejectedRegistrationDocument extends RegistrationDocument {
  const RejectedRegistrationDocument({
    required super.documentTypeId,
    required this.reason,
  });

  final String reason;

  @override
  List<Object?> get props => [documentTypeId, reason];
}
