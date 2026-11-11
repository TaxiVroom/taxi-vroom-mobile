import 'package:mobile/features/driver_home/data/models/driver_document_model.dart';
import 'package:mobile/features/driver_home/data/models/driver_vehicle_model.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';

// GET /v1/drivers/me/account: the profile, the vehicle (null without one)
// and "documents", the same object as GET /v1/drivers/me/documents. Spec
// taxi-vroom-api/docs/specs/compte-a-jour.md.
class DriverAccountModel {
  const DriverAccountModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.documents,
    this.vehicle,
  });

  factory DriverAccountModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    return DriverAccountModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      vehicle: vehicle == null ? null : DriverVehicleModel.fromJson(vehicle),
      documents: DriverDocumentModel.listFromJson(
        json['documents'] as Map<String, dynamic>,
      ),
    );
  }

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final DriverVehicleModel? vehicle;
  final List<DriverDocumentModel> documents;

  DriverAccount toDomain() => DriverAccount(
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    email: email,
    vehicle: vehicle?.toDomain(),
    documents: DriverDocuments(documents.map((m) => m.toDomain()).toList()),
  );
}
