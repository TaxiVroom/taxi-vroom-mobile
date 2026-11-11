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
  // "Maison" and "Travail", only those set, from GET /v1/me/saved-places.
  final List<SavedPlace> savedPlaces;

  // The number "Contacter le développeur" calls, from GET
  // /v1/enterprise-contact.
  final String? contactPhone;

  String get fullName => '$firstName $lastName';

  // Deleted from its row in "Compte".
  PassengerAccount withoutSavedPlace(SavedPlaceKind kind) => PassengerAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    savedPlaces: [
      for (final place in savedPlaces)
        if (place.kind != kind) place,
    ],
    contactPhone: contactPhone,
  );

  // The profile with what LoadAccountUseCase asked beside it.
  PassengerAccount complete({
    required List<SavedPlace> savedPlaces,
    required String contactPhone,
  }) => PassengerAccount(
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
