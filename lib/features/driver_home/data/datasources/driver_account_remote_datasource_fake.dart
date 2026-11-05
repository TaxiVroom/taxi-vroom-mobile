import 'package:mobile/features/driver_home/data/datasources/driver_account_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_account_model.dart';

/// Implémentation de développement avec données de test.
class DriverAccountRemoteDataSourceFake
    implements DriverAccountRemoteDataSource {
  @override
  Future<DriverAccountModel> getAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return DriverAccountModel.fromJson({
      'firstName': 'Karim',
      'lastName': 'Benali',
      'phone': '+33 6 98 76 54 32',
      'email': 'karim.taxi@exemple.fr',
      'vehicle': {
        'model': 'Toyota Corolla Touring',
        'plate': 'GH-482-KZ',
        'department': '67',
      },
    });
  }
}
