part of 'recent_destinations_bloc.dart';

sealed class RecentDestinationsEvent extends Equatable {
  const RecentDestinationsEvent();

  @override
  List<Object?> get props => [];
}

// "Votre trajet" opens.
final class RecentDestinationsRequested extends RecentDestinationsEvent {
  const RecentDestinationsRequested();
}
