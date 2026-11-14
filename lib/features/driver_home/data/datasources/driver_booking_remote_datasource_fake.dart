import 'package:mobile/core/data/models/paged_list_model.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_booking_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_booking_model.dart';
import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';

/// Implémentation de développement avec données de test, au format de l'API.
/// Deux réservations à prendre, deux déjà acceptées. Accepter ou se désister
/// fait passer une réservation d'une liste à l'autre, en mémoire ; refuser la
/// retire des disponibles.
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
        tripMeters: 14800,
        minPriceCents: 2700,
        maxPriceCents: 3300,
        customerFirstName: 'Léa',
      ),
      _booking(
        id: 'fake-available-2',
        scheduledPickup: at(2, 8, 30),
        pickupName: 'Gare de Strasbourg',
        destinationName: 'Hôpital de Hautepierre',
        tripMeters: 4700,
        minPriceCents: 1400,
        maxPriceCents: 1700,
        customerFirstName: 'Paul',
      ),
    ]);
    _accepted.addAll([
      _booking(
        id: 'fake-accepted-1',
        scheduledPickup: at(1, 8, 30),
        pickupName: 'Gare de Strasbourg',
        destinationName: 'Hôpital de Hautepierre',
        tripMeters: 4700,
        minPriceCents: 1400,
        maxPriceCents: 1700,
        customerFirstName: 'Marc',
      ),
      _booking(
        id: 'fake-accepted-2',
        scheduledPickup: at(3, 17, 45),
        pickupName: 'Place Kléber',
        destinationName: 'Parlement européen',
        tripMeters: 3100,
        minPriceCents: 1100,
        maxPriceCents: 1400,
        customerFirstName: 'Inès',
      ),
    ]);
  }

  final _available = <Map<String, dynamic>>[];
  final _accepted = <Map<String, dynamic>>[];

  @override
  Future<PagedListModel<DriverBookingModel>> getAcceptedBookings({
    required int page,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return PagedListModel.pageOf(_sorted(_accepted), page: page);
  }

  @override
  Future<PagedListModel<DriverBookingModel>> getAvailableBookings({
    required double latitude,
    required double longitude,
    required int page,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return PagedListModel.pageOf(_sorted(_available), page: page);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _move(bookingId, from: _available, to: _accepted);
  }

  @override
  Future<void> withdrawFromBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _move(bookingId, from: _accepted, to: _available);
  }

  @override
  Future<void> refuseBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _available.removeWhere((booking) => booking['id'] == bookingId);
  }

  // No fake booking reaches its deadline: "Je pars" is never shown.
  @override
  Future<DriverRideModel> departForBooking(String bookingId) =>
      throw UnsupportedError('No simulated booking can be left for.');

  void _move(
    String bookingId, {
    required List<Map<String, dynamic>> from,
    required List<Map<String, dynamic>> to,
  }) {
    final booking = from.firstWhere((b) => b['id'] == bookingId);
    from.remove(booking);
    to.add(booking);
  }

  List<DriverBookingModel> _sorted(List<Map<String, dynamic>> bookings) => [
    for (final booking in bookings) DriverBookingModel.fromJson(booking),
  ]..sort((a, b) => a.scheduledPickup.compareTo(b.scheduledPickup));

  // The JSON of GET /v1/bookings/available and /accepted.
  Map<String, dynamic> _booking({
    required String id,
    required DateTime scheduledPickup,
    required String pickupName,
    required String destinationName,
    required int tripMeters,
    required int minPriceCents,
    required int maxPriceCents,
    required String customerFirstName,
  }) => {
    'id': id,
    'pickupAt': scheduledPickup.toUtc().toIso8601String(),
    'originName': pickupName,
    'destinationName': destinationName,
    'tripMeters': tripMeters,
    'estimatedPriceMinCents': minPriceCents,
    'estimatedPriceMaxCents': maxPriceCents,
    'passengerFirstName': customerFirstName,
    'canDepart': false,
  };
}
