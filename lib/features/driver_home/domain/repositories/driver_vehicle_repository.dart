import 'package:mobile/core/domain/entities/vehicle.dart';
import 'package:mobile/core/utils/result.dart';

abstract class DriverVehicleRepository {
  // Null for a driver registered before the "Votre taxi" step existed.
  Future<Result<Vehicle?>> getVehicle();
}
