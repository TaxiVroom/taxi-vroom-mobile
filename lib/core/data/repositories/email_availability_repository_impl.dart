import 'package:mobile/core/data/datasources/email_availability_remote_datasource.dart';
import 'package:mobile/core/domain/repositories/email_availability_repository.dart';

class EmailAvailabilityRepositoryImpl implements EmailAvailabilityRepository {
  const EmailAvailabilityRepositoryImpl(this._dataSource);
  final EmailAvailabilityRemoteDataSource _dataSource;

  @override
  Future<bool> checkEmailAvailability({required String email}) =>
      _dataSource.checkEmailAvailability(email: email);
}
