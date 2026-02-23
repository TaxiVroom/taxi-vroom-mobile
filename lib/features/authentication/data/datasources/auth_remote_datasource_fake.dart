import 'package:mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';

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
    if (otp == '0000') throw Exception('Code invalide (test error)');
    return UserModel(id: 'fake-id', phoneNumber: phoneNumber, isNewUser: true);
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(id: 'fake-google-id', phoneNumber: '', isNewUser: false);
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
      isNewUser: false,
    );
  }

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return !_takenEmails.contains(email.toLowerCase().trim());
  }
}
