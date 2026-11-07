import 'package:equatable/equatable.dart';

// A French commune, e.g. Strasbourg, "67482", in the 67.
class Commune extends Equatable {
  const Commune({
    required this.code,
    required this.name,
    required this.departmentCode,
  });

  // INSEE code.
  final String code;
  final String name;
  final String departmentCode;

  @override
  List<Object?> get props => [code, name, departmentCode];
}
