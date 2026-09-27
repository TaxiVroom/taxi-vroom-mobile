import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

// Everything the "Compte" tab shows.
class PassengerAccount extends Equatable {
  const PassengerAccount({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.savedPlaces,
    required this.notificationsEnabled,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final List<SavedPlace> savedPlaces;
  final bool notificationsEnabled;

  String get fullName => '$firstName $lastName';

  PassengerAccount withNotificationsEnabled(bool enabled) => PassengerAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    savedPlaces: savedPlaces,
    notificationsEnabled: enabled,
  );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    savedPlaces,
    notificationsEnabled,
  ];
}
