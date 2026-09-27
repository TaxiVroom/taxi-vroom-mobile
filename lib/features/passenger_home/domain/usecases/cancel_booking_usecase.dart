import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<void>> call(String bookingId) =>
      _repository.cancelBooking(bookingId);
}
