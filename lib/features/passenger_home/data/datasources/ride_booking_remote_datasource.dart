import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/booked_ride_model.dart';

// Rides booked in advance.
abstract class RideBookingRemoteDataSource {
  // Books the ride estimated for later, at its price.
  Future<void> bookRide(String rideId);

  Future<void> cancelBooking(String bookingId);

  // Soonest first.
  Future<List<BookedRideModel>> getBookings();
}

// The booking is the estimated ride itself: booking only sends its id, the
// backend keeps its price and pickup time.
class RideBookingRemoteDataSourceImpl implements RideBookingRemoteDataSource {
  const RideBookingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> bookRide(String rideId) =>
      _dio.post<void>('/v1/rides/$rideId/book');

  // A booking is cancelled like a ride.
  @override
  Future<void> cancelBooking(String bookingId) =>
      _dio.post<void>('/v1/rides/$bookingId/cancel');

  @override
  Future<List<BookedRideModel>> getBookings() async {
    final response = await _dio.get<List<dynamic>>('/v1/rides/booked');
    return response.data!
        .map(
          (booking) =>
              BookedRideModel.fromJson(booking as Map<String, dynamic>),
        )
        .toList();
  }
}
