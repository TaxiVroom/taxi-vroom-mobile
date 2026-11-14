import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// A page of "Acceptées": the bookings the driver committed to.
class LoadAcceptedBookingsUseCase {
  const LoadAcceptedBookingsUseCase(this._repository);

  final DriverBookingRepository _repository;

  Future<Result<PagedList<DriverBooking>>> call({required int page}) =>
      _repository.getAcceptedBookings(page: page);
}
