import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/registration/passenger/data/datasources/registration_remote_datasource.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

/// Implémentation de développement avec données de test.
/// À remplacer par [RegistrationRemoteDataSourceImpl] lorsque le backend est prêt.
class RegistrationRemoteDataSourceFake implements RegistrationRemoteDataSource {
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
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      Future<void>.delayed(const Duration(milliseconds: 400));

}
