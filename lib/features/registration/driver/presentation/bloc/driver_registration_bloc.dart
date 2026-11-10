import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/email_validator.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/domain/entities/document_signed_urls.dart';
import 'package:mobile/features/registration/driver/domain/entities/document_type.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_document.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';
import 'package:mobile/features/registration/driver/domain/usecases/check_registration_validated_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/watch_validation_notification_opened_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_signed_url_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_types_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_uploaded_documents_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/send_registration_push_token_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/submit_registration_vehicle_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/upload_registration_document_usecase.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_event.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';
import 'package:stream_transform/stream_transform.dart';

part 'driver_registration_event.dart';
part 'driver_registration_state.dart';

class DriverRegistrationBloc extends RegistrationBloc {
  DriverRegistrationBloc({
    required DriverRegistrationFlowEntity registrationFlow,
    required UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase,
    required EnsureNotificationPermissionUseCase
    ensureNotificationPermissionUseCase,
    required CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase,
    required GetDocumentTypesUseCase getDocumentTypesUseCase,
    required UploadRegistrationDocumentUseCase
    uploadRegistrationDocumentUseCase,
    required GetUploadedDocumentsUseCase getUploadedDocumentsUseCase,
    required GetDocumentSignedUrlUseCase getDocumentSignedUrlUseCase,
    required SubmitRegistrationVehicleUseCase submitRegistrationVehicleUseCase,
    required CheckRegistrationValidatedUseCase
    checkRegistrationValidatedUseCase,
    required SendRegistrationPushTokenUseCase sendRegistrationPushTokenUseCase,
    required WatchPushedRidesUseCase watchPushedRidesUseCase,
    required WatchValidationNotificationOpenedUseCase
    watchValidationNotificationOpenedUseCase,
  }) : _ensureNotificationPermissionUseCase =
           ensureNotificationPermissionUseCase,
       _submitRegistrationVehicleUseCase = submitRegistrationVehicleUseCase,
       _checkRegistrationValidatedUseCase = checkRegistrationValidatedUseCase,
       _sendRegistrationPushTokenUseCase = sendRegistrationPushTokenUseCase,
       _watchPushedRidesUseCase = watchPushedRidesUseCase,
       _watchValidationNotificationOpenedUseCase =
           watchValidationNotificationOpenedUseCase,
       _vehicle = registrationFlow.vehicle,
       _driverId = registrationFlow.userId,
       _getDocumentTypesUseCase = getDocumentTypesUseCase,
       _uploadRegistrationDocumentUseCase = uploadRegistrationDocumentUseCase,
       _getUploadedDocumentsUseCase = getUploadedDocumentsUseCase,
       _getDocumentSignedUrlUseCase = getDocumentSignedUrlUseCase,
       super(
         userId: registrationFlow.userId,
         emailStep: DriverRegistrationStep.email,
         nameStep: DriverRegistrationStep.name,
         completeStep: DriverRegistrationStep.complete,
         updateRegistrationFlowUseCase: updateRegistrationFlowUseCase,
         checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
         // FIXME: Business logic present in the Presentation layer.
         // This orchestration (step routing based on registrationFlow) should be
         // moved to a dedicated UseCase in the Domain layer.
         // To be refactored to comply with Clean Architecture (10 years maintenance).
         initialState: _initialState(registrationFlow),
       ) {
    on<DriverRegistrationVehicleSubmitted>(_onVehicleSubmitted);
    on<DriverRegistrationReviewWatched>(_onReviewWatched);
    on<DriverRegistrationReviewChecked>(_onReviewChecked);
    on<DriverRegistrationPushTokenSent>(_onPushTokenSent);
    on<_DriverRegistrationValidationOpened>(_onValidationOpened);
    on<DriverRegistrationDocumentsContinued>(_onDocumentsContinued);
    on<DocumentTypesFetchRequested>(_onDocumentTypesFetchRequested);
    on<DocumentUploadRequested>(_onDocumentUploadRequested);
    on<DocumentsStepBackRequested>(_onDocumentsStepBackRequested);
    on<DriverRegistrationSuccessAcknowledged>(_onSuccessAcknowledged);
    on<DocumentSignedUrlsRequested>(_onDocumentSignedUrlsRequested);
  }

  final EnsureNotificationPermissionUseCase
  _ensureNotificationPermissionUseCase;
  final SubmitRegistrationVehicleUseCase _submitRegistrationVehicleUseCase;
  final CheckRegistrationValidatedUseCase _checkRegistrationValidatedUseCase;
  final SendRegistrationPushTokenUseCase _sendRegistrationPushTokenUseCase;
  final WatchPushedRidesUseCase _watchPushedRidesUseCase;
  final WatchValidationNotificationOpenedUseCase
  _watchValidationNotificationOpenedUseCase;
  final String _driverId;

  // The waiting screen reads the registration again this often, when no
  // notification can tell it sooner.
  static const _reviewCheckInterval = Duration(seconds: 30);

  // Watched once, however often the waiting screen is built.
  bool _watchesReview = false;

  // One reading at a time: the others would only ask the same.
  bool _checksReview = false;

  // The vehicle given at "Votre taxi": shown again when the driver comes
  // back to that step.
  RegistrationVehicle? _vehicle;
  final GetDocumentTypesUseCase _getDocumentTypesUseCase;
  final UploadRegistrationDocumentUseCase _uploadRegistrationDocumentUseCase;
  final GetUploadedDocumentsUseCase _getUploadedDocumentsUseCase;
  final GetDocumentSignedUrlUseCase _getDocumentSignedUrlUseCase;

  static RegistrationState _initialState(DriverRegistrationFlowEntity flow) {
    log(
      '[DriverRegistrationBloc] RegistrationFlow reçu :\n${const JsonEncoder.withIndent('  ').convert({
        'userId': flow.userId,
        'currentStep': flow.currentStep.name,
        'email': flow.email,
        'firstName': flow.firstName,
        'lastName': flow.lastName,
      })}',
    );

    return switch (flow.currentStep) {
      DriverRegistrationStep.socialLink => RegistrationSocialLinkReady(
        currentStep: flow.currentStep,
      ),
      DriverRegistrationStep.email => RegistrationEmailInputReady(
        currentStep: flow.currentStep,
        email: flow.email ?? '',
      ),
      DriverRegistrationStep.name => RegistrationNameInputReady(
        currentStep: flow.currentStep,
        email: flow.email ?? '',
        firstName: flow.firstName ?? '',
        lastName: flow.lastName ?? '',
      ),
      DriverRegistrationStep.vehicle => DriverRegVehicleReady(
        currentStep: flow.currentStep,
        email: flow.email ?? '',
        firstName: flow.firstName ?? '',
        lastName: flow.lastName ?? '',
        vehicle: flow.vehicle,
      ),
      DriverRegistrationStep.documents => DriverRegDocumentsReady(
        currentStep: flow.currentStep,
        email: flow.email ?? '',
        firstName: flow.firstName ?? '',
        lastName: flow.lastName ?? '',
      ),
      DriverRegistrationStep.pendingReview => DriverRegSuccessReady(
        currentStep: flow.currentStep,
        email: flow.email ?? '',
        firstName: flow.firstName ?? '',
        lastName: flow.lastName ?? '',
      ),
      // uploadedDocuments chargés au montage de la page via DocumentTypesFetchRequested.
      DriverRegistrationStep.documentsCorrection =>
        DriverRegDocumentsCorrectionReady(
          currentStep: flow.currentStep,
          uploadedDocuments: const [],
          email: flow.email ?? '',
          firstName: flow.firstName ?? '',
          lastName: flow.lastName ?? '',
        ),
      DriverRegistrationStep.complete => DriverRegSuccessReady(
        currentStep: flow.currentStep,
        email: flow.email ?? '',
        firstName: flow.firstName ?? '',
        lastName: flow.lastName ?? '',
      ),
    };
  }

  @override
  RegistrationState stateForStep(RegistrationStep step) => switch (step) {
    DriverRegistrationStep.socialLink => RegistrationSocialLinkReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ),
    DriverRegistrationStep.email => RegistrationEmailInputReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
      isFormatValid: EmailValidator.isValid(state.email),
    ),
    DriverRegistrationStep.name => RegistrationNameInputReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
      isFormValid: state.firstName.isNotEmpty && state.lastName.isNotEmpty,
    ),
    DriverRegistrationStep.vehicle => DriverRegVehicleReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
      vehicle: _vehicle,
    ),
    DriverRegistrationStep.documents => DriverRegDocumentsReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ),
    DriverRegistrationStep.pendingReview => DriverRegSuccessReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ),
    DriverRegistrationStep.documentsCorrection =>
      DriverRegDocumentsCorrectionReady(
        currentStep: step,
        // uploadedDocuments portés depuis l'état courant si déjà disponibles —
        // évite de les perdre lors d'une navigation arrière/avant.
        uploadedDocuments: state is DriverRegDocumentsCorrectionReady
            ? (state as DriverRegDocumentsCorrectionReady).uploadedDocuments
            : const [],
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ),
    DriverRegistrationStep.complete => DriverRegSuccessReady(
      currentStep: step,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ),
    _ => throw StateError(
      'Unexpected step for driver registration: $step',
    ),
  };

  // "Continuer" on "Votre taxi": the vehicle is kept, then the documents.
  Future<void> _onVehicleSubmitted(
    DriverRegistrationVehicleSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverRegVehicleReady || currentState.isSubmitting) {
      return;
    }
    emit(currentState.copyWith(isSubmitting: true, vehicle: event.vehicle));
    switch (await _submitRegistrationVehicleUseCase(
      userId: _driverId,
      vehicle: event.vehicle,
    )) {
      case Ok():
        _vehicle = event.vehicle;
        emit(stateForStep(DriverRegistrationStep.documents));
      case Error(:final error):
        emit(
          currentState.copyWith(
            vehicle: event.vehicle,
            failure: error,
          ),
        );
    }
  }

  // A notification received with the app on screen, or the time passed:
  // read the registration again. Spec
  // taxi-vroom-api/docs/specs/validation-du-dossier.md.
  Future<void> _onReviewWatched(
    DriverRegistrationReviewWatched event,
    Emitter<RegistrationState> emit,
  ) async {
    if (_watchesReview) return;
    _watchesReview = true;
    final Stream<void> signs = _watchPushedRidesUseCase().map<void>((_) {});
    final everyInterval = Stream<void>.periodic(_reviewCheckInterval);
    await Future.wait([
      emit.onEach<void>(
        signs.merge(everyInterval),
        onData: (_) => add(const DriverRegistrationReviewChecked()),
      ),
      // "Dossier validé" tapped: the home at once, no reading to wait for.
      // Spec taxi-vroom-api/docs/specs/validation-du-dossier.md, step 3 ter.
      emit.onEach<void>(
        _watchValidationNotificationOpenedUseCase(),
        onData: (_) => add(const _DriverRegistrationValidationOpened()),
      ),
    ]);
  }

  void _onValidationOpened(
    _DriverRegistrationValidationOpened event,
    Emitter<RegistrationState> emit,
  ) {
    final current = state;
    if (current is! DriverRegSuccessReady) return;
    emit(
      RegistrationAuthenticated(
        currentStep: DriverRegistrationStep.complete,
        email: current.email,
        firstName: current.firstName,
        lastName: current.lastName,
      ),
    );
  }

  // Validated: the driver goes to the home, as after "Accéder".
  Future<void> _onReviewChecked(
    DriverRegistrationReviewChecked event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is! DriverRegSuccessReady || _checksReview) return;
    _checksReview = true;
    final review = await _checkRegistrationValidatedUseCase();
    _checksReview = false;
    if (state is! DriverRegSuccessReady) return;
    if (review == RegistrationReview.newDocumentAsked) {
      emit(
        DriverRegDocumentsReady(
          currentStep: DriverRegistrationStep.documents,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
          isNewDocumentAsked: true,
        ),
      );
      return;
    }
    if (review != RegistrationReview.validated) return;
    emit(
      RegistrationAuthenticated(
        currentStep: DriverRegistrationStep.complete,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ),
    );
  }

  // Not sent: the driver is not told, the waiting screen still finds out.
  Future<void> _onPushTokenSent(
    DriverRegistrationPushTokenSent event,
    Emitter<RegistrationState> emit,
  ) async {
    await _sendRegistrationPushTokenUseCase();
  }

  Future<void> _onDocumentsContinued(
    DriverRegistrationDocumentsContinued event,
    Emitter<RegistrationState> emit,
  ) async {
    log(
      '[DriverRegistrationBloc] Dossier soumis pour review → en attente admin',
    );
    final fromStep = state.currentStep;
    emit(
      DriverRegDocumentsSubmitting(
        currentStep: fromStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ),
    );
    try {
      await notifyRegistrationReadyForReview(fromStep);
      emit(
        DriverRegSuccessReady(
          currentStep: DriverRegistrationStep.pendingReview,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ),
      );
    } catch (e) {
      log('[DriverRegistrationBloc] Erreur soumission dossier : $e');
      emit(
        RegistrationError(
          message: e.toString(),
          currentStep: fromStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ),
      );
    }
  }

  Future<void> _onDocumentTypesFetchRequested(
    DocumentTypesFetchRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverRegDocumentsReady &&
        currentState is! DriverRegDocumentsCorrectionReady)
      return;

    log(
      '[DriverRegistrationBloc] Chargement des types de documents et des uploads existants...',
    );

    switch (currentState) {
      case DriverRegDocumentsReady():
        emit(currentState.copyWith(isLoadingDocumentTypes: true));
      case DriverRegDocumentsCorrectionReady():
        emit(currentState.copyWith(isLoadingDocumentTypes: true));
      case _:
        break;
    }

    try {
      final results = await Future.wait([
        _getDocumentTypesUseCase(),
        _getUploadedDocumentsUseCase(),
      ]);
      final documentTypes = results[0] as List<DocumentType>;
      final uploadedDocuments = results[1] as List<RegistrationDocument>;
      final uploadedIds = uploadedDocuments
          .map((d) => d.documentTypeId)
          .toList();

      final initialStatuses = {
        for (final id in uploadedIds) id: DocumentUploadStatus.succeeded,
      };

      // Pré-fetch des URLs signées pour tous les docs déjà uploadés en parallèle.
      final signedUrls = await _prefetchSignedUrls(documentTypes, uploadedIds);

      log(
        '[DriverRegistrationBloc] ${documentTypes.length} types chargés, ${uploadedIds.length} déjà uploadés.',
      );

      switch (currentState) {
        case DriverRegDocumentsReady():
          emit(
            currentState.copyWith(
              isLoadingDocumentTypes: false,
              documentTypes: documentTypes,
              uploadStatuses: initialStatuses,
              signedUrls: signedUrls,
              lastValidDays: {
                for (final document in uploadedDocuments)
                  if (document.lastValidDay case final day?)
                    document.documentTypeId: day,
              },
            ),
          );
        case DriverRegDocumentsCorrectionReady():
          emit(
            currentState.copyWith(
              isLoadingDocumentTypes: false,
              uploadedDocuments: uploadedDocuments,
              documentTypes: documentTypes,
              uploadStatuses: initialStatuses,
              signedUrls: signedUrls,
            ),
          );
        case _:
          break;
      }
    } catch (e) {
      log('[DriverRegistrationBloc] Erreur chargement : $e');
      switch (currentState) {
        case DriverRegDocumentsReady():
          emit(currentState.copyWith(isLoadingDocumentTypes: false));
        case DriverRegDocumentsCorrectionReady():
          emit(currentState.copyWith(isLoadingDocumentTypes: false));
        case _:
          break;
      }
    }
  }

  Future<Map<String, DocumentSignedUrls>> _prefetchSignedUrls(
    List<DocumentType> documentTypes,
    List<String> uploadedIds,
  ) async {
    final uploadedTypes = documentTypes.where(
      (dt) => uploadedIds.contains(dt.id),
    );

    final entries = await Future.wait(
      uploadedTypes.map((dt) async {
        final urls = await Future.wait([
          _getDocumentSignedUrlUseCase(documentTypeId: dt.id, side: 'front'),
          if (dt.backRequired)
            _getDocumentSignedUrlUseCase(documentTypeId: dt.id, side: 'back'),
        ]);
        return MapEntry(
          dt.id,
          DocumentSignedUrls(
            frontUrl: urls[0],
            backUrl: dt.backRequired ? urls[1] : null,
          ),
        );
      }),
    );

    return Map.fromEntries(entries);
  }

  Future<void> _onDocumentUploadRequested(
    DocumentUploadRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverRegDocumentsReady &&
        currentState is! DriverRegDocumentsCorrectionReady)
      return;

    log(
      '[DriverRegistrationBloc] Upload — documentTypeId=${event.documentTypeId}',
    );

    switch (currentState) {
      case DriverRegDocumentsReady():
        emit(
          currentState.copyWith(
            uploadStatuses: {
              ...currentState.uploadStatuses,
              event.documentTypeId: DocumentUploadStatus.uploading,
            },
          ),
        );
      case DriverRegDocumentsCorrectionReady():
        emit(
          currentState.copyWith(
            uploadStatuses: {
              ...currentState.uploadStatuses,
              event.documentTypeId: DocumentUploadStatus.uploading,
            },
          ),
        );
      case _:
        break;
    }

    try {
      await _uploadRegistrationDocumentUseCase(
        documentTypeId: event.documentTypeId,
        frontFilePath: event.frontFilePath,
        backFilePath: event.backFilePath,
        expiresAt: event.expiresAt,
      );
      log(
        '[DriverRegistrationBloc] Upload réussi — documentTypeId=${event.documentTypeId}',
      );
      switch (currentState) {
        case DriverRegDocumentsReady():
          emit(
            currentState.copyWith(
              uploadStatuses: {
                ...currentState.uploadStatuses,
                event.documentTypeId: DocumentUploadStatus.succeeded,
              },
              signedUrls: Map<String, DocumentSignedUrls>.from(
                currentState.signedUrls,
              )..remove(event.documentTypeId),
              lastValidDays: {
                ...currentState.lastValidDays,
                if (event.expiresAt case final day?) event.documentTypeId: day,
              },
            ),
          );
        case DriverRegDocumentsCorrectionReady():
          emit(
            currentState.copyWith(
              uploadStatuses: {
                ...currentState.uploadStatuses,
                event.documentTypeId: DocumentUploadStatus.succeeded,
              },
              signedUrls: Map<String, DocumentSignedUrls>.from(
                currentState.signedUrls,
              )..remove(event.documentTypeId),
              // Marque ce document comme corrigé — débloque le bouton de soumission
              // quand tous les documents rejetés ont été re-uploadés.
              correctedDocumentIds: {
                ...currentState.correctedDocumentIds,
                event.documentTypeId,
              },
            ),
          );
        case _:
          break;
      }
    } catch (e) {
      log(
        '[DriverRegistrationBloc] Échec upload — documentTypeId=${event.documentTypeId} : $e',
      );
      switch (currentState) {
        case DriverRegDocumentsReady():
          emit(
            currentState.copyWith(
              uploadStatuses: {
                ...currentState.uploadStatuses,
                event.documentTypeId: DocumentUploadStatus.failed,
              },
            ),
          );
        case DriverRegDocumentsCorrectionReady():
          emit(
            currentState.copyWith(
              uploadStatuses: {
                ...currentState.uploadStatuses,
                event.documentTypeId: DocumentUploadStatus.failed,
              },
            ),
          );
        case _:
          break;
      }
    }
  }

  void _onDocumentsStepBackRequested(
    DocumentsStepBackRequested event,
    Emitter<RegistrationState> emit,
  ) {
    log('[DriverRegistrationBloc] ← VehiclePage');
    emit(stateForStep(DriverRegistrationStep.vehicle));
  }

  void _onSuccessAcknowledged(
    DriverRegistrationSuccessAcknowledged event,
    Emitter<RegistrationState> emit,
  ) {
    log('[DriverRegistrationBloc] Succès confirmé → Home');
    emit(
      RegistrationAuthenticated(
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ),
    );
  }

  Future<void> _onDocumentSignedUrlsRequested(
    DocumentSignedUrlsRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverRegDocumentsReady) return;

    log(
      '[DriverRegistrationBloc] Chargement URLs signées — documentTypeId=${event.documentTypeId}',
    );

    try {
      final futures = [
        _getDocumentSignedUrlUseCase(
          documentTypeId: event.documentTypeId,
          side: 'front',
        ),
        if (event.backRequired)
          _getDocumentSignedUrlUseCase(
            documentTypeId: event.documentTypeId,
            side: 'back',
          ),
      ];
      final urls = await Future.wait(futures);
      final signedUrls = DocumentSignedUrls(
        frontUrl: urls[0],
        backUrl: event.backRequired ? urls[1] : null,
      );

      log(
        '[DriverRegistrationBloc] URLs signées chargées — documentTypeId=${event.documentTypeId}',
      );
      emit(
        currentState.copyWith(
          signedUrls: {
            ...currentState.signedUrls,
            event.documentTypeId: signedUrls,
          },
        ),
      );
    } catch (e) {
      log(
        '[DriverRegistrationBloc] Erreur chargement URLs signées — documentTypeId=${event.documentTypeId} : $e',
      );
    }
  }

  @override
  Future<void> notifyPermissionGranted() =>
      _ensureNotificationPermissionUseCase();

  // No-op: the driver flow never shows the notifications screen, its registration
  // is completed by the admin's document validation.
  @override
  Future<Result<void>> completeRegistration() async => const Result.ok(null);
}
