import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/vehicle_color.dart';

// A driver's taxi, as the passenger looks for it and the driver sees it in
// their account. Spec taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md.
class Vehicle extends Equatable {
  const Vehicle({
    required this.model,
    required this.color,
    required this.plate,
    required this.adsNumber,
    required this.communeName,
  });

  // Make and model, e.g. "Renault Austral".
  final String model;
  final VehicleColor color;

  // As on the plate, e.g. "AB-123-CD".
  final String plate;

  // The autorisation de stationnement of the taxi in its commune, e.g. "118".
  final String adsNumber;
  final String communeName;

  // "Renault Austral grise"; the model alone when the color says nothing.
  String get description => switch (color.adjective) {
    final adjective? => '$model $adjective',
    null => model,
  };

  // "Taxi n° 118, Strasbourg".
  String get licence => 'Taxi n° $adsNumber, $communeName';

  @override
  List<Object?> get props => [model, color, plate, adsNumber, communeName];
}
