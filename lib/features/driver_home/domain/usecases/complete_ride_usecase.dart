import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Valider et repasser libre": the amount is confirmed, the passenger rated.
class CompleteRideUseCase {
  const CompleteRideUseCase(this._driverRideRepository);

  // The legal price comes from the taxi's meter only: never guessed.
  static const _missingMeterAmount = ValidationFailure(
    'Saisissez le montant affiché sur le taximètre.',
  );

  final DriverRideRepository _driverRideRepository;

  Future<Result<void>> call({
    required String rideId,
    required RideCheckout checkout,
    required int customerRating,
  }) async {
    final meterCents = checkout.meterCents;
    if (meterCents == null) return const Result.error(_missingMeterAmount);
    return _driverRideRepository.completeRide(
      rideId: rideId,
      meterCents: meterCents,
      supplements: checkout.addedSupplements,
      customerRating: customerRating,
    );
  }
}
