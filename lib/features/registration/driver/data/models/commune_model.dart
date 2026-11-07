import 'package:mobile/features/registration/driver/domain/entities/commune.dart';

// One commune of GET https://geo.api.gouv.fr/communes, e.g.
// {"nom":"Strasbourg","code":"67482","codeDepartement":"67"}.
class CommuneModel {
  const CommuneModel({
    required this.code,
    required this.name,
    required this.departmentCode,
  });

  factory CommuneModel.fromJson(Map<String, dynamic> json) => CommuneModel(
    code: json['code'] as String,
    name: json['nom'] as String,
    departmentCode: json['codeDepartement'] as String,
  );

  final String code;
  final String name;
  final String departmentCode;

  Commune toDomain() =>
      Commune(code: code, name: name, departmentCode: departmentCode);
}
