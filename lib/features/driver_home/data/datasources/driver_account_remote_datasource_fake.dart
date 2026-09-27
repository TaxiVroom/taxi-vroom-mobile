import 'package:mobile/features/driver_home/data/datasources/driver_account_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_account_model.dart';

/// Implémentation de développement avec données de test.
/// Garde en mémoire le choix des notifications.
class DriverAccountRemoteDataSourceFake
    implements DriverAccountRemoteDataSource {
  bool _notificationsEnabled = true;

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
      'notificationsEnabled': _notificationsEnabled,
    });
  }

  @override
  Future<void> setNotificationsEnabled({required bool enabled}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _notificationsEnabled = enabled;
  }
}
