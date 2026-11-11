import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/vehicle.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';

// Everything the driver's "Compte" tab shows, from one call to the API. The
// notifications line reads the phone's permission instead: NotificationsRow.
class DriverAccount extends Equatable {
  const DriverAccount({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.documents,
    this.vehicle,
    this.contactPhone,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  // Given at the "Votre taxi" step of the registration; null for a driver
  // registered before it existed.
  final Vehicle? vehicle;

  final DriverDocuments documents;

  // The number "Contacter le développeur" calls, from GET
  // /v1/enterprise-contact, asked with the account by
  // LoadDriverAccountUseCase.
  final String? contactPhone;

  String get fullName => '$firstName $lastName';

  DriverAccount withContactPhone(String contactPhone) => DriverAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    documents: documents,
    vehicle: vehicle,
    contactPhone: contactPhone,
  );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    vehicle,
    documents,
    contactPhone,
  ];
}
