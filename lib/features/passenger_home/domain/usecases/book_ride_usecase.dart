import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class BookRideUseCase {
  const BookRideUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<String>> call({
    required Coordinates origin,
    required Place destination,
    required TaxiOffer offer,
    required DateTime scheduledPickup,
  }) => _repository.bookRide(
    origin: origin,
    destination: destination,
    offer: offer,
    scheduledPickup: scheduledPickup,
  );
}
