import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/features/driver_home/data/models/driver_booking_model.dart';
import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';

abstract class DriverBookingRemoteDataSource {
  Future<List<DriverBookingModel>> getAcceptedBookings();

  // Those without a driver around this position.
  Future<List<DriverBookingModel>> getAvailableBookings({
    required double latitude,
    required double longitude,
  });

  Future<void> acceptBooking(String bookingId);

  Future<void> withdrawFromBooking(String bookingId);

  Future<void> refuseBooking(String bookingId);

  // "Je pars": the ride the driver now drives to, as after an accepted offer.
  Future<DriverRideModel> departForBooking(String bookingId);
}

// A booking is a ride booked for later: its id is the ride's.
class DriverBookingRemoteDataSourceImpl
    implements DriverBookingRemoteDataSource {
  const DriverBookingRemoteDataSourceImpl(this._dio, this._database);

  final Dio _dio;
  final FirebaseDatabase _database;

  @override
  Future<List<DriverBookingModel>> getAcceptedBookings() =>
      _getBookings('/v1/bookings/accepted');

  @override
  Future<List<DriverBookingModel>> getAvailableBookings({
    required double latitude,
    required double longitude,
  }) => _getBookings(
    '/v1/bookings/available',
    queryParameters: {'latitude': latitude, 'longitude': longitude},
  );

  @override
  Future<void> acceptBooking(String bookingId) =>
      _dio.post<void>('/v1/rides/$bookingId/booking/accept');

  @override
  Future<void> withdrawFromBooking(String bookingId) =>
      _dio.post<void>('/v1/rides/$bookingId/booking/withdraw');

  @override
  Future<void> refuseBooking(String bookingId) =>
      _dio.post<void>('/v1/rides/$bookingId/booking/refuse');

  // Like accepting an offer: the ride is readable at rides/<id> once it is
  // the driver's, published by the API before it answers.
  // Docs: https://firebase.google.com/docs/database/flutter/read-and-write
  @override
  Future<DriverRideModel> departForBooking(String bookingId) async {
    await _dio.post<void>('/v1/rides/$bookingId/booking/depart');
    final ride = await _database.ref('rides/$bookingId').get();
    return DriverRideModel.fromSnapshot(bookingId, ride);
  }

  Future<List<DriverBookingModel>> _getBookings(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return response.data!
        .map(
          (booking) =>
              DriverBookingModel.fromJson(booking as Map<String, dynamic>),
        )
        .toList();
  }
}
