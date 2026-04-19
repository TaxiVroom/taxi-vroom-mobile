import 'package:mobile/features/registration/driver/data/datasources/driver_registration_remote_datasource.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

class DriverRegistrationRepositoryImpl implements DriverRegistrationRepository {
  const DriverRegistrationRepositoryImpl(this._dataSource);

  final DriverRegistrationRemoteDataSource _dataSource;

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) =>
      _dataSource.updateRegistrationFlow(userId: userId, update: update);

}
