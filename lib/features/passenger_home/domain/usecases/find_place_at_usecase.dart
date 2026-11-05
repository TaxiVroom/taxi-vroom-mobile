import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/address_repository.dart';

// "Choisir sur la carte": the place under the pin. A point without a known
// address, or when the service fails, stays choosable: the taxi only needs
// the point. Spec point-de-prise-en-charge.md.
class FindPlaceAtUseCase {
  const FindPlaceAtUseCase(this._repository);

  final AddressRepository _repository;

  static Place unknownPlaceAt(Coordinates point) => Place(
    name: 'Point sur la carte',
    address: 'Adresse inconnue',
    coordinates: point,
  );

  Future<Place> call(Coordinates point) async =>
      switch (await _repository.findPlaceAt(point)) {
        Ok(value: final place?) => place,
        Ok() || Error() => unknownPlaceAt(point),
      };
}
