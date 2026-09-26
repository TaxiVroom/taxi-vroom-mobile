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

// Location unavailable: permission denied or location services turned off.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}
