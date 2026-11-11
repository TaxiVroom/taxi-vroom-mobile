import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

// A saved address of the "Compte" tab, still simulated: the API has none.
class SavedPlaceModel {
  const SavedPlaceModel({required this.label, required this.address});

  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) =>
      SavedPlaceModel(
        label: json['label'] as String,
        address: json['address'] as String,
      );

  final String label;
  final String address;

  SavedPlace toDomain() => SavedPlace(label: label, address: address);
}
