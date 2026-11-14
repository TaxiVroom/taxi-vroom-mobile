import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// One page of "À venir" in "Mes courses".
class LoadBookingsUseCase {
  const LoadBookingsUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<PagedList<BookedRide>>> call({required int page}) =>
      _repository.getBookings(page: page);
}
