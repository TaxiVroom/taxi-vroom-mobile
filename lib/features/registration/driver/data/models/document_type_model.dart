import 'package:mobile/features/registration/driver/domain/entities/document_type.dart';

class DocumentTypeModel {
  const DocumentTypeModel({
    required this.id,
    required this.name,
    required this.backRequired,
  });

  final String id;
  final String name;
  final bool backRequired;

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) =>
      DocumentTypeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        backRequired: json['backRequired'] as bool,
      );

  DocumentType toDomain() =>
      DocumentType(id: id, name: name, backRequired: backRequired);
}
