import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  const Vehicle({
    required this.model,
    required this.color,
    required this.plate,
    required this.department,
  });

  final String model;
  final String color;

  // French plate, e.g. "GH-482-KZ", with its department code (e.g. "67").
  final String plate;
  final String department;

  @override
  List<Object?> get props => [model, color, plate, department];
}
