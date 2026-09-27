import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// A ride the driver accepted, from the drive to the passenger to the arrival.
class DriverRide extends Equatable {
  const DriverRide({
    required this.id,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerPhone,
    required this.pickupName,
    required this.pickup,
    required this.destinationName,
    required this.destination,
    this.customerNote,
  });

  final String id;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;
  final String pickupName;
  final Coordinates pickup;
  final String destinationName;
  final Coordinates destination;

  // E.g. "Je suis devant la pharmacie.".
  final String? customerNote;

  String get customerFullName => '$customerFirstName $customerLastName';

  @override
  List<Object?> get props => [
    id,
    customerFirstName,
    customerLastName,
    customerPhone,
    pickupName,
    pickup,
    destinationName,
    destination,
    customerNote,
  ];
}
