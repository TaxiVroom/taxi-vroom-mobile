abstract class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// The request breaks a business rule (e.g. a pickup time too soon).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// The price shown is too old to be ordered: a new one must be shown first.
class EstimateExpiredFailure extends ValidationFailure {
  const EstimateExpiredFailure(super.message);
}

// Another driver or registration already has this plate. Spec
// taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md, point 7.
class VehiclePlateTakenFailure extends ValidationFailure {
  const VehiclePlateTakenFailure(super.message);
}

// Another driver or registration already has this taxi number in this
// commune.
class VehicleLicenceTakenFailure extends ValidationFailure {
  const VehicleLicenceTakenFailure(super.message);
}

// Location unavailable: permission denied or location services turned off.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

// The phone could not tell or change a permission.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

// The phone could not do it, such as opening another app.
class DeviceFailure extends Failure {
  const DeviceFailure(super.message);
}
