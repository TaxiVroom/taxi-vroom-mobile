import 'package:equatable/equatable.dart';

// Everything the driver's "Compte" tab shows.
class DriverAccount extends Equatable {
  const DriverAccount({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.vehicleModel,
    required this.plate,
    required this.plateDepartment,
    required this.notificationsEnabled,
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

  final bool notificationsEnabled;

  String get fullName => '$firstName $lastName';

  DriverAccount withNotificationsEnabled({required bool enabled}) =>
      DriverAccount(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        vehicleModel: vehicleModel,
        plate: plate,
        plateDepartment: plateDepartment,
        notificationsEnabled: enabled,
      );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    vehicleModel,
    plate,
    plateDepartment,
    notificationsEnabled,
  ];
}
