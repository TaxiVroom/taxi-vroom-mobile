import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';

class DriverRideModel {
  const DriverRideModel({
    required this.id,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerPhone,
    required this.customerNote,
    required this.pickupName,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationName,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  factory DriverRideModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>;
    final pickup = json['pickup'] as Map<String, dynamic>;
    final destination = json['destination'] as Map<String, dynamic>;
    return DriverRideModel(
      id: json['id'] as String,
      customerFirstName: customer['firstName'] as String,
      customerLastName: customer['lastName'] as String,
      customerPhone: customer['phone'] as String,
      customerNote: customer['note'] as String?,
      pickupName: pickup['name'] as String,
      pickupLatitude: (pickup['latitude'] as num).toDouble(),
      pickupLongitude: (pickup['longitude'] as num).toDouble(),
      destinationName: destination['name'] as String,
      destinationLatitude: (destination['latitude'] as num).toDouble(),
      destinationLongitude: (destination['longitude'] as num).toDouble(),
    );
  }

  // From rides/<rideId>, readable by the driver once the ride is theirs.
  factory DriverRideModel.fromSnapshot(String rideId, DataSnapshot ride) {
    final passenger = ride.child('passenger');
    return DriverRideModel.fromJson({
      'id': rideId,
      'customer': {
        'firstName': passenger.child('firstName').value! as String,
        'lastName': passenger.child('lastName').value! as String,
        'phone': passenger.child('phone').value! as String,
      },
      'pickup': placeJson(ride.child('pickup')),
      'destination': placeJson(ride.child('destination')),
    });
  }

  static Map<String, dynamic> placeJson(DataSnapshot place) => {
    'name': place.child('name').value! as String,
    'latitude': place.child('latitude').value! as num,
    'longitude': place.child('longitude').value! as num,
  };

  final String id;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;
  final String? customerNote;
  final String pickupName;
  final double pickupLatitude;
  final double pickupLongitude;
  final String destinationName;
  final double destinationLatitude;
  final double destinationLongitude;

  DriverRide toDomain() => DriverRide(
    id: id,
    customerFirstName: customerFirstName,
    customerLastName: customerLastName,
    customerPhone: customerPhone,
    customerNote: customerNote,
    pickupName: pickupName,
    pickup: Coordinates(latitude: pickupLatitude, longitude: pickupLongitude),
    destinationName: destinationName,
    destination: Coordinates(
      latitude: destinationLatitude,
      longitude: destinationLongitude,
    ),
  );
}
