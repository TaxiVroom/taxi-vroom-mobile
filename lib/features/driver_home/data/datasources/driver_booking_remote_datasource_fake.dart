import 'package:mobile/features/driver_home/data/datasources/driver_booking_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_booking_model.dart';

/// Implémentation de développement avec données de test.
/// Deux réservations à prendre, deux déjà acceptées. Accepter une réservation
/// la fait passer d'une liste à l'autre, en mémoire.
class DriverBookingRemoteDataSourceFake
    implements DriverBookingRemoteDataSource {
  DriverBookingRemoteDataSourceFake() {
    final today = DateTime.now();
    DateTime at(int days, int hour, int minute) =>
        DateTime(today.year, today.month, today.day + days, hour, minute);

    _available.addAll([
      _booking(
        id: 'fake-available-1',
        scheduledPickup: at(1, 6, 15),
        pickupName: '8 rue du Dôme',
        destinationName: 'Aéroport Strasbourg-Entzheim',
        distanceKm: 14.8,
        minPriceCents: 2700,
        maxPriceCents: 3300,
        customerFirstName: 'Léa',
        luggageCount: 2,
      ),
      _booking(
        id: 'fake-available-2',
        scheduledPickup: at(2, 8, 30),
        pickupName: 'Gare de Strasbourg',
        destinationName: 'Hôpital de Hautepierre',
        distanceKm: 4.7,
        minPriceCents: 1400,
        maxPriceCents: 1700,
        customerFirstName: 'Paul',
        luggageCount: 0,
        requirement: 'Taxi Accès demandé',
      ),
    ]);
    _accepted.addAll([
      _booking(
        id: 'fake-accepted-1',
        scheduledPickup: at(1, 8, 30),
        pickupName: 'Gare de Strasbourg',
        destinationName: 'Hôpital de Hautepierre',
        distanceKm: 4.7,
        minPriceCents: 1400,
        maxPriceCents: 1700,
        customerFirstName: 'Marc',
        luggageCount: 2,
      ),
      _booking(
        id: 'fake-accepted-2',
        scheduledPickup: at(3, 17, 45),
        pickupName: 'Place Kléber',
        destinationName: 'Parlement européen',
        distanceKm: 3.1,
        minPriceCents: 1100,
        maxPriceCents: 1400,
        customerFirstName: 'Inès',
        luggageCount: 1,
      ),
    ]);
  }

  final _available = <Map<String, dynamic>>[];
  final _accepted = <Map<String, dynamic>>[];

  @override
  Future<List<DriverBookingModel>> getAcceptedBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _sorted(_accepted);
  }

  @override
  Future<List<DriverBookingModel>> getAvailableBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _sorted(_available);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final booking = _available.firstWhere((b) => b['id'] == bookingId);
    _available.remove(booking);
    _accepted.add(booking);
  }

  List<DriverBookingModel> _sorted(List<Map<String, dynamic>> bookings) => [
    for (final booking in bookings) DriverBookingModel.fromJson(booking),
  ]..sort((a, b) => a.scheduledPickup.compareTo(b.scheduledPickup));

  Map<String, dynamic> _booking({
    required String id,
    required DateTime scheduledPickup,
    required String pickupName,
    required String destinationName,
    required double distanceKm,
    required int minPriceCents,
    required int maxPriceCents,
    required String customerFirstName,
    required int luggageCount,
    String? requirement,
  }) => {
    'id': id,
    'scheduledPickup': scheduledPickup.toIso8601String(),
    'pickupName': pickupName,
    'destinationName': destinationName,
    'distanceKm': distanceKm,
    'minPriceCents': minPriceCents,
    'maxPriceCents': maxPriceCents,
    'customerFirstName': customerFirstName,
    'passengerCount': 1,
    'luggageCount': luggageCount,
    'requirement': requirement,
  };
}
