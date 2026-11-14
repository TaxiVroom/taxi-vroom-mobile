import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// A page of "Disponibles" after the first, around the position the first one
// was read at.
class LoadAvailableBookingsPageUseCase {
  const LoadAvailableBookingsPageUseCase(this._repository);

  final DriverBookingRepository _repository;

  Future<Result<PagedList<DriverBooking>>> call({
    required Coordinates around,
    required int page,
  }) => _repository.getAvailableBookings(around: around, page: page);
}
