import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';

// What happens to the requests offered to an online driver.
sealed class RideRequestUpdate extends Equatable {
  const RideRequestUpdate();
}

// A new request, with its roads.
final class IncomingRideRequest extends RideRequestUpdate {
  const IncomingRideRequest({required this.offer});

  final RoutedRideRequest offer;

  @override
  List<Object?> get props => [offer];
}

// The request was taken back before its time ran out: the passenger
// cancelled it, unless the driver's own answer reached the server first.
final class CancelledRideRequest extends RideRequestUpdate {
  const CancelledRideRequest({required this.requestId});

  final String requestId;

  @override
  List<Object?> get props => [requestId];
}
