part of 'driver_registration_bloc.dart';

enum DocumentUploadStatus { uploading, succeeded, failed }

final class DriverRegDocumentsReady extends RegistrationState {
  const DriverRegDocumentsReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
    this.documentTypes = const [],
    this.uploadStatuses = const {},
    this.signedUrls = const {},
    this.isLoadingDocumentTypes = false,
  });

  final List<DocumentType> documentTypes;

  // Key = documentTypeId. Absent from the map means the upload has not started yet.
  final Map<String, DocumentUploadStatus> uploadStatuses;

  // Key = documentTypeId. Populated lazily when the user opens the replacement sheet.
  final Map<String, DocumentSignedUrls> signedUrls;

  final bool isLoadingDocumentTypes;

  bool get areAllDocumentsUploaded =>
      documentTypes.isNotEmpty &&
      documentTypes.every(
        (documentType) =>
            uploadStatuses[documentType.id] == DocumentUploadStatus.succeeded,
      );

  bool isDocumentTappable(String documentTypeId) =>
      uploadStatuses[documentTypeId] != DocumentUploadStatus.uploading;

  bool canFinalizeUpload({
    required String documentTypeId,
    required bool hasFront,
    required bool hasBack,
  }) {
    final isReplacement =
        uploadStatuses[documentTypeId] == DocumentUploadStatus.succeeded;
    final backRequired = documentTypes
        .firstWhere((dt) => dt.id == documentTypeId)
        .backRequired;

    if (isReplacement) return hasFront || hasBack;
    return hasFront && (!backRequired || hasBack);
  }

  DriverRegDocumentsReady copyWith({
    List<DocumentType>? documentTypes,
    Map<String, DocumentUploadStatus>? uploadStatuses,
    Map<String, DocumentSignedUrls>? signedUrls,
    bool? isLoadingDocumentTypes,
  }) =>
      DriverRegDocumentsReady(
        currentStep: currentStep,
        email: email,
        firstName: firstName,
        lastName: lastName,
        documentTypes: documentTypes ?? this.documentTypes,
        uploadStatuses: uploadStatuses ?? this.uploadStatuses,
        signedUrls: signedUrls ?? this.signedUrls,
        isLoadingDocumentTypes:
            isLoadingDocumentTypes ?? this.isLoadingDocumentTypes,
      );

  @override
  List<Object?> get props => [
        ...super.props,
        documentTypes,
        uploadStatuses,
        signedUrls,
        isLoadingDocumentTypes,
      ];
}

final class DriverRegDocumentsCorrectionReady extends RegistrationState {
  const DriverRegDocumentsCorrectionReady({
    required super.currentStep,
    required this.uploadedDocuments,
    super.email,
    super.firstName,
    super.lastName,
    this.documentTypes = const [],
    this.uploadStatuses = const {},
    this.signedUrls = const {},
    this.correctedDocumentIds = const {},
    this.isLoadingDocumentTypes = false,
  });

  // Documents déjà soumis avec leur résultat de review — permet d'afficher
  // la raison de rejet pour chaque document refusé par l'admin.
  final List<RegistrationDocument> uploadedDocuments;

  final List<DocumentType> documentTypes;

  // Key = documentTypeId. Absent from the map means the upload has not started yet.
  final Map<String, DocumentUploadStatus> uploadStatuses;

  // Key = documentTypeId. Populated lazily when the user opens the replacement sheet.
  final Map<String, DocumentSignedUrls> signedUrls;

  // IDs des documents re-uploadés pendant la correction.
  final Set<String> correctedDocumentIds;

  final bool isLoadingDocumentTypes;

  List<RejectedRegistrationDocument> get rejectedDocuments =>
      uploadedDocuments.whereType<RejectedRegistrationDocument>().toList();

  // Le chauffeur ne peut soumettre que si tous les documents rejetés ont été corrigés.
  bool get areAllRejectedDocumentsCorrected =>
      rejectedDocuments.isNotEmpty &&
      rejectedDocuments.every(
        (doc) => correctedDocumentIds.contains(doc.documentTypeId),
      );

  bool isDocumentTappable(String documentTypeId) =>
      uploadStatuses[documentTypeId] != DocumentUploadStatus.uploading;

  bool canFinalizeUpload({
    required String documentTypeId,
    required bool hasFront,
    required bool hasBack,
  }) {
    final backRequired = documentTypes
        .firstWhere((dt) => dt.id == documentTypeId)
        .backRequired;
    final isReplacement =
        uploadStatuses[documentTypeId] == DocumentUploadStatus.succeeded;

    if (isReplacement) return hasFront || hasBack;
    return hasFront && (!backRequired || hasBack);
  }

  DriverRegDocumentsCorrectionReady copyWith({
    List<RegistrationDocument>? uploadedDocuments,
    List<DocumentType>? documentTypes,
    Map<String, DocumentUploadStatus>? uploadStatuses,
    Map<String, DocumentSignedUrls>? signedUrls,
    Set<String>? correctedDocumentIds,
    bool? isLoadingDocumentTypes,
  }) =>
      DriverRegDocumentsCorrectionReady(
        currentStep: currentStep,
        email: email,
        firstName: firstName,
        lastName: lastName,
        uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
        documentTypes: documentTypes ?? this.documentTypes,
        uploadStatuses: uploadStatuses ?? this.uploadStatuses,
        signedUrls: signedUrls ?? this.signedUrls,
        correctedDocumentIds: correctedDocumentIds ?? this.correctedDocumentIds,
        isLoadingDocumentTypes:
            isLoadingDocumentTypes ?? this.isLoadingDocumentTypes,
      );

  @override
  List<Object?> get props => [
        ...super.props,
        uploadedDocuments,
        documentTypes,
        uploadStatuses,
        signedUrls,
        correctedDocumentIds,
        isLoadingDocumentTypes,
      ];
}

final class DriverRegDocumentsSubmitting extends RegistrationState {
  const DriverRegDocumentsSubmitting({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class DriverRegSuccessReady extends RegistrationState {
  const DriverRegSuccessReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}
