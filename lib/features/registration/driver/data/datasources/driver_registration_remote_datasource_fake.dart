import 'package:mobile/features/registration/driver/data/datasources/driver_registration_remote_datasource.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

/// Implémentation de développement avec données de test.
/// À remplacer par [DriverRegistrationRemoteDataSourceImpl] lorsque le backend est prêt.
class DriverRegistrationRemoteDataSourceFake
    implements DriverRegistrationRemoteDataSource {
  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      Future<void>.delayed(const Duration(milliseconds: 400));

}
