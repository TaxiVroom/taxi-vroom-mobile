import 'package:mobile/features/registration/driver/domain/entities/registration_document.dart';

// TODO: Migrer vers freezed — gère nativement les sealed classes avec fromJson/toJson généré.
sealed class RegistrationDocumentModel {
  const RegistrationDocumentModel({required this.documentTypeId});

  final String documentTypeId;

  factory RegistrationDocumentModel.fromJson(Map<String, dynamic> json) {
    final documentTypeId = json['documentTypeId'] as String;
    final reviewResult = json['reviewResult'] as Map<String, dynamic>;
    final status = reviewResult['status'] as String;

    return switch (status) {
      'SUBMITTED' =>
        SubmittedRegistrationDocumentModel(documentTypeId: documentTypeId),
      'VALIDATED' =>
        ValidatedRegistrationDocumentModel(documentTypeId: documentTypeId),
      'REJECTED' => RejectedRegistrationDocumentModel(
          documentTypeId: documentTypeId,
          reason: reviewResult['rejectionReason'] as String? ??
              (throw FormatException(
                'Contrat API violé : REJECTED sans rejectionReason',
              )),
        ),
      _ => throw FormatException('Statut de review inconnu : $status'),
    };
  }

  RegistrationDocument toDomain();
}

final class SubmittedRegistrationDocumentModel extends RegistrationDocumentModel {
  const SubmittedRegistrationDocumentModel({required super.documentTypeId});

  @override
  RegistrationDocument toDomain() =>
      SubmittedRegistrationDocument(documentTypeId: documentTypeId);
}

final class ValidatedRegistrationDocumentModel extends RegistrationDocumentModel {
  const ValidatedRegistrationDocumentModel({required super.documentTypeId});

  @override
  RegistrationDocument toDomain() =>
      ValidatedRegistrationDocument(documentTypeId: documentTypeId);
}

final class RejectedRegistrationDocumentModel extends RegistrationDocumentModel {
  const RejectedRegistrationDocumentModel({
    required super.documentTypeId,
    required this.reason,
  });

  final String reason;

  @override
  RegistrationDocument toDomain() =>
      RejectedRegistrationDocument(documentTypeId: documentTypeId, reason: reason);
}
