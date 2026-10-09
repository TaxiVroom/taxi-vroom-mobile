import 'package:mobile/features/driver_home/data/datasources/ride_request_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';
import 'package:mobile/features/driver_home/data/models/ride_request_model.dart';

/// Implémentation de développement avec données de test.
///
/// [sendsRideRequests] : à true, une demande de course arrive quelques
/// secondes après le passage en ligne, puis régulièrement ; à false, le
/// chauffeur attend sans jamais recevoir de demande.
class RideRequestRemoteDataSourceFake implements RideRequestRemoteDataSource {
  RideRequestRemoteDataSourceFake({required this.sendsRideRequests});

  final bool sendsRideRequests;

  static const _firstRequestDelay = Duration(seconds: 5);
  static const _nextRequestDelay = Duration(seconds: 30);

  // The requests sent, by id: accepting one turns it into a ride.
  final _sentRequests = <String, Map<String, dynamic>>{};

  @override
  Stream<RideRequestModel?> watchRideRequests({
    required double latitude,
    required double longitude,
  }) async* {
    if (!sendsRideRequests) return;
    await Future<void>.delayed(_firstRequestDelay);
    while (true) {
      yield RideRequestModel.fromJson(
        _request(latitude: latitude, longitude: longitude),
      );
      await Future<void>.delayed(_nextRequestDelay);
    }
  }

  // Placed around the driver, so the roads exist wherever they are.
  Map<String, dynamic> _request({
    required double latitude,
    required double longitude,
  }) {
    final id = 'fake-request-${_sentRequests.length + 1}';
    return _sentRequests[id] = {
      'id': id,
      'sentAt': DateTime.now().toIso8601String(),
      // A short ride (about 2 km), to test the whole ride quickly.
      'minPriceCents': 700,
      'maxPriceCents': 900,
      'distanceKm': 2.2,
      'pickup': {
        'name': 'Place Broglie',
        'latitude': latitude + 0.0085,
        'longitude': longitude + 0.0030,
      },
      'destination': {
        'name': 'Gare de Strasbourg',
        'latitude': latitude + 0.0185,
        'longitude': longitude + 0.0180,
      },
      'customer': {
        'firstName': 'Camille',
        'lastName': 'Martin',
        'rating': 4.8,
        'phone': '+33 6 12 34 56 78',
        'note': 'Je suis devant la pharmacie.',
      },
      'passengerCount': 1,
      'luggageCount': 1,
    };
  }

  @override
  Future<DriverRideModel> acceptRideRequest(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final request = _sentRequests[requestId]!;
    return DriverRideModel.fromJson({
      'id': 'fake-ride-$requestId',
      'customer': request['customer'],
      'pickup': request['pickup'],
      'destination': request['destination'],
    });
  }

  @override
  Future<void> declineRideRequest(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
