import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// "Réserver le taxi": the offer was priced for the pickup time.
class BookRideUseCase {
  const BookRideUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<String>> call(TaxiOffer offer) => _repository.bookRide(offer);
}
