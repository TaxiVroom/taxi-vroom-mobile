part of 'driver_registration_bloc.dart';

// L'utilisateur valide l'étape documents et soumet son dossier.
final class DriverRegistrationDocumentsContinued extends RegistrationEvent {
  const DriverRegistrationDocumentsContinued();
}

// L'utilisateur entre dans l'étape documents — on charge la liste depuis l'API.
final class DocumentTypesFetchRequested extends RegistrationEvent {
  const DocumentTypesFetchRequested();
}

// L'utilisateur a sélectionné et recadré ses photos pour un document.
final class DocumentUploadRequested extends RegistrationEvent {
  const DocumentUploadRequested({
    required this.documentTypeId,
    this.frontFilePath,
    this.backFilePath,
  });

  final String documentTypeId;
  final String? frontFilePath;
  final String? backFilePath;
}

// L'utilisateur appuie sur le bouton retour depuis l'étape documents.
final class DocumentsStepBackRequested extends RegistrationEvent {
  const DocumentsStepBackRequested();
}

// L'utilisateur a lu le message de succès et veut accéder à l'application.
final class DriverRegistrationSuccessAcknowledged extends RegistrationEvent {
  const DriverRegistrationSuccessAcknowledged();
}

// L'utilisateur ouvre la sheet de remplacement pour un document déjà uploadé.
final class DocumentSignedUrlsRequested extends RegistrationEvent {
  const DocumentSignedUrlsRequested({
    required this.documentTypeId,
    required this.backRequired,
  });

  final String documentTypeId;
  final bool backRequired;
}
