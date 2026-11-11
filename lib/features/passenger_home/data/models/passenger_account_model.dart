import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';

// GET /v1/me, e.g. {"role":"PASSENGER","firstName":"Jean",
// "lastName":"Dupont","phone":"+33612345678","email":"jean@exemple.fr"}.
// The role is read at the app's start, not here.
class PassengerAccountModel {
  const PassengerAccountModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory PassengerAccountModel.fromJson(Map<String, dynamic> json) =>
      PassengerAccountModel(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
      );

  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  // The saved places come from another call: PassengerAccount.complete.
  PassengerAccount toDomain() => PassengerAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    savedPlaces: const [],
  );
}
