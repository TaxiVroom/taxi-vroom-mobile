part of 'ride_bloc.dart';

sealed class RideState extends Equatable {
  const RideState();

  @override
  List<Object?> get props => [];
}

final class RideLoading extends RideState {
  const RideLoading();
}

final class RideTracking extends RideState {
  const RideTracking({
    required this.ride,
    this.remainingRoute,
    this.isSubmitting = false,
  });

  final Ride ride;

  // Road left to the destination, once in the taxi.
  final RideRoute? remainingRoute;

  // A cancellation or a rating is being sent.
  final bool isSubmitting;

  @override
  List<Object?> get props => [ride, remainingRoute, isSubmitting];
}

// Cancelled, or completed and rated: the flow leaves the ride screen.
final class RideEnded extends RideState {
  const RideEnded();
}

final class RideFailure extends RideState {
  const RideFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
