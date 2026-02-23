import 'package:mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp({required String phoneNumber});
  Future<UserModel> verifyOtp({required String phoneNumber, required String otp});
  Future<UserModel> linkGoogleAccount();
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });
  Future<bool> checkEmailAvailability({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> sendOtp({required String phoneNumber}) =>
      Future<void>.delayed(const Duration(seconds: 1));

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return UserModel(id: 'mock-id', phoneNumber: phoneNumber, isNewUser: true);
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(id: 'mock-google-id', phoneNumber: '', isNewUser: false);
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
      id: 'mock-email-id',
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
    return true;
  }
}
