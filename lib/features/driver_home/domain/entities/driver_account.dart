import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/vehicle.dart';

// Everything the driver's "Compte" tab shows. The notifications line reads
// the phone's permission instead: NotificationsRow.
class DriverAccount extends Equatable {
  const DriverAccount({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.vehicle,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  // Given at the "Votre taxi" step of the registration; null for a driver
  // registered before it existed.
  final Vehicle? vehicle;

  String get fullName => '$firstName $lastName';

  DriverAccount withVehicle(Vehicle? vehicle) => DriverAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    vehicle: vehicle,
  );

  @override
  List<Object?> get props => [firstName, lastName, phone, email, vehicle];
}
