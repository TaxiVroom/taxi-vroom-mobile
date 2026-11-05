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

// Location unavailable: permission denied or location services turned off.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

// The phone could not tell or change a permission.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
