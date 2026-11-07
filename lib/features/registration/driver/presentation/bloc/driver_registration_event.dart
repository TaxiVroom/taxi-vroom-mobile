part of 'driver_registration_bloc.dart';

// "Continuer" on "Votre taxi".
final class DriverRegistrationVehicleSubmitted extends RegistrationEvent {
  const DriverRegistrationVehicleSubmitted({required this.vehicle});

  final RegistrationVehicle vehicle;

  @override
  List<Object?> get props => [vehicle];
}

// "Dossier en cours de vérification" is shown: the registration is read
// again on each notification received and every 30 s, until it is complete.
final class DriverRegistrationReviewWatched extends RegistrationEvent {
  const DriverRegistrationReviewWatched();
}

// The app came back on screen, or a sign came: is the registration complete?
final class DriverRegistrationReviewChecked extends RegistrationEvent {
  const DriverRegistrationReviewChecked();
}

// The notifications are allowed on the waiting screen: the phone's token
// goes to the registration.
final class DriverRegistrationPushTokenSent extends RegistrationEvent {
  const DriverRegistrationPushTokenSent();
}

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
