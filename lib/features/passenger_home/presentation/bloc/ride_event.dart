part of 'ride_bloc.dart';

sealed class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object?> get props => [];
}

// The ride screen is shown, or the passenger taps "Réessayer".
final class RideStarted extends RideEvent {
  const RideStarted();
}

final class RideCancelRequested extends RideEvent {
  const RideCancelRequested();
}

// The passenger leaves a ride no driver took.
final class RideLeft extends RideEvent {
  const RideLeft();
}

// The passenger taps "Terminer" on the end-of-ride screen.
final class RideRatingSubmitted extends RideEvent {
  const RideRatingSubmitted({
    required this.stars,
    required this.compliments,
    required this.tipCents,
  });

  final int stars;
  final List<String> compliments;
  final int tipCents;

  @override
  List<Object?> get props => [stars, compliments, tipCents];
}
