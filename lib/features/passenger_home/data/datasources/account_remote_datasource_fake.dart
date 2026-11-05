import 'package:mobile/features/passenger_home/data/datasources/account_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/passenger_account_model.dart';

/// Implémentation de développement avec données de test.
class AccountRemoteDataSourceFake implements AccountRemoteDataSource {
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
    });
  }
}
