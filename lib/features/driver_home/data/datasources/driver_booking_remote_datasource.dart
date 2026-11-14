import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/data/models/paged_list_model.dart';
import 'package:mobile/features/driver_home/data/models/driver_booking_model.dart';
import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';

abstract class DriverBookingRemoteDataSource {
  // One page, the first one is 0.
  Future<PagedListModel<DriverBookingModel>> getAcceptedBookings({
    required int page,
  });

  // One page of those without a driver around this position.
  Future<PagedListModel<DriverBookingModel>> getAvailableBookings({
    required double latitude,
    required double longitude,
    required int page,
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
  Future<PagedListModel<DriverBookingModel>> getAcceptedBookings({
    required int page,
  }) => _getBookings('/v1/bookings/accepted', page: page);

  @override
  Future<PagedListModel<DriverBookingModel>> getAvailableBookings({
    required double latitude,
    required double longitude,
    required int page,
  }) => _getBookings(
    '/v1/bookings/available',
    page: page,
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

  Future<PagedListModel<DriverBookingModel>> _getBookings(
    String path, {
    required int page,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        ...?queryParameters,
        'limit': AppConstants.listPageSize,
        'page': page,
      },
    );
    return PagedListModel.fromJson(response.data!, DriverBookingModel.fromJson);
  }
}
