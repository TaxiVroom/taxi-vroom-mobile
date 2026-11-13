import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/vehicle_color.dart';

// "Votre taxi": what the passengers will look for. Spec
// taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md.
class RegistrationVehicle extends Equatable {
  const RegistrationVehicle({
    required this.model,
    required this.color,
    required this.plate,
    required this.adsNumber,
    required this.communeCode,
    required this.communeName,
    required this.passengerSeats,
  });

  // Make and model in one, e.g. "Renault Austral".
  final String model;
  final VehicleColor color;

  // As on the plate, e.g. "AB-123-CD".
  final String plate;

  // The autorisation de stationnement, the "Taxi n° 118".
  final String adsNumber;

  // The commune de rattachement: its INSEE code and its name.
  final String communeCode;
  final String communeName;

  // The passenger seats of the taxi, from 1 to 8: a taxi has eight seats at
  // most. Only taxis with as many seats as passengers get a ride. Spec
  // taxi-vroom-api/docs/specs/nombre-de-passagers.md.
  final int passengerSeats;

  // The current French plates: two letters, three digits, two letters,
  // whatever the spaces, dashes or case typed. Null otherwise.
  static String? formatPlate(String typed) {
    final compact = typed.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    final parts = RegExp(r'^([A-Z]{2})(\d{3})([A-Z]{2})$').firstMatch(compact);
    if (parts == null) return null;
    return '${parts[1]}-${parts[2]}-${parts[3]}';
  }

  @override
  List<Object?> get props => [
    model,
    color,
    plate,
    adsNumber,
    communeCode,
    communeName,
    passengerSeats,
  ];
}
