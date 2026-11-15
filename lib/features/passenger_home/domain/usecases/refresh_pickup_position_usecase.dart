import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

// The pickup "Position actuelle" is where the phone is when the passenger
// leaves the home to order, not where it was when the app opened. A pickup the
// passenger chose is never replaced. Spec
// taxi-vroom-api/docs/specs/point-de-prise-en-charge.md, step 6.
class RefreshPickupPositionUseCase {
  const RefreshPickupPositionUseCase(this._locationRepository);

  final LocationRepository _locationRepository;

  Future<Result<PassengerHome>> call({
    required PassengerHome home,
    required Place? chosen,
  }) async {
    if (chosen != null) return Result.ok(home);

    return switch (await _locationRepository.getCurrentPosition()) {
      Ok(:final value) => Result.ok(home.withPosition(value)),
      Error(:final error) => Result.error(error),
    };
  }
}
