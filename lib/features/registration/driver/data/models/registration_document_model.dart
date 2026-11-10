import 'package:mobile/features/registration/driver/domain/entities/registration_document.dart';

// TODO: Migrer vers freezed — gère nativement les sealed classes avec fromJson/toJson généré.
sealed class RegistrationDocumentModel {
  const RegistrationDocumentModel({
    required this.documentTypeId,
    this.lastValidDay,
  });

  final String documentTypeId;

  // "2026-11-20", null when the type does not expire.
  final String? lastValidDay;

  factory RegistrationDocumentModel.fromJson(Map<String, dynamic> json) {
    final documentTypeId = json['documentTypeId'] as String;
    final reviewResult = json['reviewResult'] as Map<String, dynamic>;
    final status = reviewResult['status'] as String;
    final lastValidDay = json['lastValidDay'] as String?;

    return switch (status) {
      'SUBMITTED' => SubmittedRegistrationDocumentModel(
        documentTypeId: documentTypeId,
        lastValidDay: lastValidDay,
      ),
      'VALIDATED' => ValidatedRegistrationDocumentModel(
        documentTypeId: documentTypeId,
        lastValidDay: lastValidDay,
      ),
      'REJECTED' => RejectedRegistrationDocumentModel(
        documentTypeId: documentTypeId,
        lastValidDay: lastValidDay,
        reason:
            reviewResult['rejectionReason'] as String? ??
            (throw FormatException(
              'Contrat API violé : REJECTED sans rejectionReason',
            )),
      ),
      _ => throw FormatException('Statut de review inconnu : $status'),
    };
  }

  RegistrationDocument toDomain();

  DateTime? get _lastValidDay =>
      lastValidDay == null ? null : DateTime.parse(lastValidDay!);
}

final class SubmittedRegistrationDocumentModel
    extends RegistrationDocumentModel {
  const SubmittedRegistrationDocumentModel({
    required super.documentTypeId,
    super.lastValidDay,
  });

  @override
  RegistrationDocument toDomain() => SubmittedRegistrationDocument(
    documentTypeId: documentTypeId,
    lastValidDay: _lastValidDay,
  );
}

final class ValidatedRegistrationDocumentModel
    extends RegistrationDocumentModel {
  const ValidatedRegistrationDocumentModel({
    required super.documentTypeId,
    super.lastValidDay,
  });

  @override
  RegistrationDocument toDomain() => ValidatedRegistrationDocument(
    documentTypeId: documentTypeId,
    lastValidDay: _lastValidDay,
  );
}

final class RejectedRegistrationDocumentModel
    extends RegistrationDocumentModel {
  const RejectedRegistrationDocumentModel({
    required super.documentTypeId,
    required this.reason,
    super.lastValidDay,
  });

  final String reason;

  @override
  RegistrationDocument toDomain() => RejectedRegistrationDocument(
    documentTypeId: documentTypeId,
    reason: reason,
    lastValidDay: _lastValidDay,
  );
}
