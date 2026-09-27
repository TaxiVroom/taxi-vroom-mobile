import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/registration/driver/data/models/driver_registration_flow_model.dart';
import 'package:mobile/features/registration/passenger/data/models/passenger_registration_flow_model.dart';

/// Implémentation de développement avec données de test.
/// À remplacer par [AuthRemoteDataSourceImpl] lorsque le backend est prêt.
class AuthRemoteDataSourceFake implements AuthRemoteDataSource {
  @override
  Future<void> sendOtp({required String phoneNumber}) =>
      Future<void>.delayed(const Duration(seconds: 1));

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    // 🧪 Test : OTP "000000" déclenche une AuthError
    if (otp == '000000') throw Exception('Code invalide (test error)');
    return UserModel(id: 'fake-semi-complete-id', phoneNumber: phoneNumber);
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(id: 'fake-google-id', phoneNumber: '');
  }

  @override
  // ignore: avoid_unused_constructor_parameters
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({
    required String userId,
    required UserRole role,
    required String phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (role == UserRole.driver) {
      // 🧪 Chauffeur — userId pilote l'étape de reprise :
      // 'fake-driver-documents-id'   → étape documents (upload en cours)
      // 'fake-driver-pending-id'     → dossier soumis, en attente de review
      // 'fake-driver-correction-id'  → dossier refusé, correction demandée
      // tout autre id                → nouvel utilisateur, étape socialLink
      return switch (userId) {
        'fake-driver-documents-id' => DriverRegistrationFlowModel(
          userId: userId,
          currentStep: DriverRegistrationStep.documents,
          email: 'driver@example.com',
          firstName: 'Jean',
          lastName: 'Dupont',
        ),
        'fake-driver-pending-id' => DriverRegistrationFlowModel(
          userId: userId,
          currentStep: DriverRegistrationStep.pendingReview,
          email: 'driver@example.com',
          firstName: 'Jean',
          lastName: 'Dupont',
        ),
        'fake-driver-correction-id' => DriverRegistrationFlowModel(
          userId: userId,
          currentStep: DriverRegistrationStep.documentsCorrection,
          email: 'driver@example.com',
          firstName: 'Jean',
          lastName: 'Dupont',
        ),
        _ => DriverRegistrationFlowModel(
          userId: userId,
          currentStep: DriverRegistrationStep.socialLink,
        ),
      };
    }
    // 🧪 'fake-complete-id'       → inscription terminée
    // 🧪 'fake-name-id'           → en cours, étape nom (email déjà fourni)
    // 🧪 'fake-semi-complete-id'  → en cours, étape nom (email fourni, pas de nom)
    // 🧪 'fake-email-id'          → méthode choisie (email), mais email pas encore soumis
    // 🧪 tout autre id            → nouvel utilisateur, étape socialLink
    return switch (userId) {
      'fake-complete-id' => PassengerRegistrationFlowModel(
        userId: userId,
        currentStep: PassengerRegistrationStep.complete,
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
      ),
      'fake-name-id' => PassengerRegistrationFlowModel(
        userId: userId,
        currentStep: PassengerRegistrationStep.name,
        email: 'john@example.com',
      ),
      'fake-semi-complete-id' => PassengerRegistrationFlowModel(
        userId: userId,
        currentStep: PassengerRegistrationStep.name,
        email: 'john@example.com',
        firstName: null,
        lastName: null,
      ),
      'fake-email-id' => PassengerRegistrationFlowModel(
        userId: userId,
        currentStep: PassengerRegistrationStep.email,
      ),
      _ => PassengerRegistrationFlowModel(
        userId: userId,
        currentStep: PassengerRegistrationStep.socialLink,
      ),
    };
  }

  @override
  Future<void> signOut() =>
      Future<void>.delayed(const Duration(milliseconds: 300));
}
