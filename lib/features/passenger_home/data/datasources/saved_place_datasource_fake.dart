import 'package:mobile/features/passenger_home/data/models/saved_place_model.dart';

abstract class SavedPlaceDataSource {
  Future<List<SavedPlaceModel>> getSavedPlaces();
}

// No saved address in the API yet: kept simulated by the user's decision,
// spec taxi-vroom-api/docs/specs/compte-a-jour.md.
class SavedPlaceDataSourceFake implements SavedPlaceDataSource {
  @override
  Future<List<SavedPlaceModel>> getSavedPlaces() async => [
    for (final json in const [
      {'label': 'Maison', 'address': '8 rue du Dôme, Strasbourg'},
      {'label': 'Travail', 'address': "Parc d'innovation, Illkirch"},
    ])
      SavedPlaceModel.fromJson(json),
  ];
}
