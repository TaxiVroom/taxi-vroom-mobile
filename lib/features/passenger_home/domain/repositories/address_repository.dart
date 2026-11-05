import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

abstract class AddressRepository {
  // The address at [point], at that exact point; null when there is none,
  // as outside France.
  Future<Result<Place?>> findPlaceAt(Coordinates point);
}
