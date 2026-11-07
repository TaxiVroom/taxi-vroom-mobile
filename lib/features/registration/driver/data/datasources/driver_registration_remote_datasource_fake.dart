import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/data/datasources/driver_registration_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/models/driver_registration_flow_model.dart';
import 'package:mobile/features/registration/driver/data/models/registration_vehicle_model.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

/// Implémentation de développement avec données de test.
/// À remplacer par [DriverRegistrationRemoteDataSourceImpl] lorsque le backend est prêt.
class DriverRegistrationRemoteDataSourceFake
    implements DriverRegistrationRemoteDataSource {
  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) => Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<void> saveVehicle(RegistrationVehicleModel vehicle) =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  // Still under review: the waiting screen stays.
  @override
  Future<DriverRegistrationFlowModel> getRegistrationFlow() async =>
      const DriverRegistrationFlowModel(
        userId: 'fake-driver-pending-id',
        currentStep: DriverRegistrationStep.pendingReview,
      );

  @override
  Future<void> savePushToken(String token) =>
      Future<void>.delayed(const Duration(milliseconds: 400));
}
