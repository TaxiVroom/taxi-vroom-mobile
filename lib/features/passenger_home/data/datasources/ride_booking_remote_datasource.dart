import 'package:dio/dio.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/data/models/paged_list_model.dart';
import 'package:mobile/features/passenger_home/data/models/booked_ride_model.dart';

// Rides booked in advance.
abstract class RideBookingRemoteDataSource {
  // Books the ride estimated for later, at its price.
  Future<void> bookRide(String rideId);

  Future<void> cancelBooking(String bookingId);

  // One page, soonest first. The first page is 0.
  Future<PagedListModel<BookedRideModel>> getBookings({required int page});
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
  Future<PagedListModel<BookedRideModel>> getBookings({
    required int page,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/rides/booked',
      queryParameters: {'limit': AppConstants.listPageSize, 'page': page},
    );
    return PagedListModel.fromJson(response.data!, BookedRideModel.fromJson);
  }
}
