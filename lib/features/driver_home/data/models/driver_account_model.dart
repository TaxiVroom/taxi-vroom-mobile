import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';

class DriverAccountModel {
  const DriverAccountModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.vehicleModel,
    required this.plate,
    required this.plateDepartment,
    required this.notificationsEnabled,
  });

  factory DriverAccountModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>;
    return DriverAccountModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      vehicleModel: vehicle['model'] as String,
      plate: vehicle['plate'] as String,
      plateDepartment: vehicle['department'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
    );
  }

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String vehicleModel;
  final String plate;
  final String plateDepartment;
  final bool notificationsEnabled;

  DriverAccount toDomain() => DriverAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    vehicleModel: vehicleModel,
    plate: plate,
    plateDepartment: plateDepartment,
    notificationsEnabled: notificationsEnabled,
  );
}
