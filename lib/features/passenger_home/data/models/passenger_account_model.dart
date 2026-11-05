import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

class PassengerAccountModel {
  const PassengerAccountModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.savedPlaces,
  });

  factory PassengerAccountModel.fromJson(Map<String, dynamic> json) =>
      PassengerAccountModel(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        savedPlaces: [
          for (final place in json['savedPlaces'] as List<dynamic>)
            (
              label: (place as Map<String, dynamic>)['label'] as String,
              address: place['address'] as String,
            ),
        ],
      );

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final List<({String label, String address})> savedPlaces;

  PassengerAccount toDomain() => PassengerAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    savedPlaces: [
      for (final place in savedPlaces)
        SavedPlace(label: place.label, address: place.address),
    ],
  );
}
