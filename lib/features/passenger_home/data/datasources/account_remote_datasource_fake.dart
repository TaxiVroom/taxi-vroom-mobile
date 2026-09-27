import 'package:mobile/features/passenger_home/data/datasources/account_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/passenger_account_model.dart';

/// Implémentation de développement avec données de test.
/// Garde en mémoire le choix des notifications.
class AccountRemoteDataSourceFake implements AccountRemoteDataSource {
  bool _notificationsEnabled = true;

  @override
  Future<PassengerAccountModel> getAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return PassengerAccountModel.fromJson({
      'firstName': 'Camille',
      'lastName': 'Martin',
      'phone': '+33 6 12 34 56 78',
      'email': 'camille@exemple.fr',
      'savedPlaces': [
        {'label': 'Maison', 'address': '8 rue du Dôme, Strasbourg'},
        {'label': 'Travail', 'address': "Parc d'innovation, Illkirch"},
      ],
      'notificationsEnabled': _notificationsEnabled,
    });
  }

  @override
  Future<void> setNotificationsEnabled({required bool enabled}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _notificationsEnabled = enabled;
  }
}
