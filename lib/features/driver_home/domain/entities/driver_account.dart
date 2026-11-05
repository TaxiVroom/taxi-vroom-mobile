import 'package:equatable/equatable.dart';

// Everything the driver's "Compte" tab shows. The notifications line reads
// the phone's permission instead: NotificationsRow.
class DriverAccount extends Equatable {
  const DriverAccount({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.vehicleModel,
    required this.plate,
    required this.plateDepartment,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  // E.g. "Toyota Corolla Touring".
  final String vehicleModel;

  // E.g. "GH-482-KZ".
  final String plate;
  final String plateDepartment;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    vehicleModel,
    plate,
    plateDepartment,
  ];
}
