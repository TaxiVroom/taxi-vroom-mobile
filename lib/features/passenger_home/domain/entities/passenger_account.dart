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
    this.contactPhone,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final List<SavedPlace> savedPlaces;

  // The number "Contacter le développeur" calls, from GET
  // /v1/enterprise-contact, asked with the account by LoadAccountUseCase.
  final String? contactPhone;

  String get fullName => '$firstName $lastName';

  PassengerAccount withContactPhone(String contactPhone) => PassengerAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    savedPlaces: savedPlaces,
    contactPhone: contactPhone,
  );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    savedPlaces,
    contactPhone,
  ];
}
