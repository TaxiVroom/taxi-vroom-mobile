part of 'guidance_bloc.dart';

sealed class GuidanceEvent extends Equatable {
  const GuidanceEvent();

  @override
  List<Object?> get props => [];
}

// The screen is shown, or the driver taps "Réessayer".
final class GuidanceStarted extends GuidanceEvent {
  const GuidanceStarted({required this.to, this.from});

  final Coordinates to;

  // Null: from the driver's current position.
  final Coordinates? from;

  @override
  List<Object?> get props => [to, from];
}
