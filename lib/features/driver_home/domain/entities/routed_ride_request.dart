import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';

// A ride request with its two roads: to the passenger, then to the
// destination. A road is null when it could not be computed.
class RoutedRideRequest extends Equatable {
  const RoutedRideRequest({
    required this.request,
    this.approach,
    this.trip,
  });

  final RideRequest request;

  // From the driver to the pickup.
  final RideRoute? approach;

  // From the pickup to the destination.
  final RideRoute? trip;

  @override
  List<Object?> get props => [request, approach, trip];
}
