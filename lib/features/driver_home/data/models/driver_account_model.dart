import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';

// The profile of the "Compte" tab, still simulated. The vehicle comes from
// GET /v1/drivers/me/vehicle: DriverVehicleModel.
class DriverAccountModel {
  const DriverAccountModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory DriverAccountModel.fromJson(Map<String, dynamic> json) =>
      DriverAccountModel(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
      );

  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  DriverAccount toDomain() => DriverAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
  );
}
