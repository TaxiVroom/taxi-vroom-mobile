import 'package:equatable/equatable.dart';

class DocumentType extends Equatable {
  const DocumentType({
    required this.id,
    required this.name,
    required this.backRequired,
  });

  final String id;
  final String name;
  final bool backRequired;

  @override
  List<Object?> get props => [id, name, backRequired];
}
