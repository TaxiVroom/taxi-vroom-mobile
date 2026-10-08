import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class RequestRideUseCase {
  const RequestRideUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<String>> call({
    required Coordinates origin,
    required Place destination,
    required TaxiOffer offer,
  }) => _repository.requestRide(
    origin: origin,
    destination: destination,
    offer: offer,
  );
}
