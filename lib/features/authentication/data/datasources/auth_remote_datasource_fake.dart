import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/models/passenger_registration_flow_model.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_update.dart';

/// Implémentation de développement avec données de test.
/// À remplacer par [AuthRemoteDataSourceImpl] lorsque le backend est prêt.
class AuthRemoteDataSourceFake implements AuthRemoteDataSource {
  static const _takenEmails = {'taken@example.com', 'test@test.com'};

  @override
  Future<void> sendOtp({required String phoneNumber}) =>
      Future<void>.delayed(const Duration(seconds: 1));

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    // 🧪 Test : OTP "0000" déclenche une AuthError
    if (otp == '000000') throw Exception('Code invalide (test error)');
    return UserModel(id: 'fake-semi-complete-id', phoneNumber: phoneNumber);
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(id: 'fake-google-id', phoneNumber: '');
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'fake-email-id',
      phoneNumber: phoneNumber,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return !_takenEmails.contains(email.toLowerCase().trim());
  }

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<void> createPassenger({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) =>
      Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
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
}
