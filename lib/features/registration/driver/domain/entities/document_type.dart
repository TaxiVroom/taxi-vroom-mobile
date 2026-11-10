import 'package:equatable/equatable.dart';

class DocumentType extends Equatable {
  const DocumentType({
    required this.id,
    required this.name,
    required this.backRequired,
    required this.expires,
  });

  final String id;
  final String name;
  final bool backRequired;
  // Its date of end of validity is asked.
  final bool expires;

  @override
  List<Object?> get props => [id, name, backRequired, expires];
}
