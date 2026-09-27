import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';

class DriverDocumentModel {
  const DriverDocumentModel({
    required this.kind,
    required this.name,
    required this.detail,
    required this.status,
    required this.proofName,
  });

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) =>
      DriverDocumentModel(
        kind: json['kind'] as String,
        name: json['name'] as String,
        detail: json['detail'] as String,
        status: json['status'] as String,
        proofName: json['proofName'] as String,
      );

  final String kind;
  final String name;
  final String detail;
  final String status;
  final String proofName;

  DriverDocument toDomain() => DriverDocument(
    kind: DriverDocumentKind.values.byName(kind),
    name: name,
    detail: detail,
    status: DriverDocumentStatus.values.byName(status),
    proofName: proofName,
  );
}
