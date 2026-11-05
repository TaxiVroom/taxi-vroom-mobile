import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

// Everything the "Compte" tab shows. The notifications line reads the
// phone's permission instead: NotificationsRow.
class PassengerAccount extends Equatable {
  const PassengerAccount({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.savedPlaces,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final List<SavedPlace> savedPlaces;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [firstName, lastName, phone, email, savedPlaces];
}
