part of 'recent_destinations_bloc.dart';

sealed class RecentDestinationsState extends Equatable {
  const RecentDestinationsState();

  @override
  List<Object?> get props => [];
}

// A small loader under the fields until the API answers.
final class RecentDestinationsLoading extends RecentDestinationsState {
  const RecentDestinationsLoading();
}

// Empty without a completed ride, or when the call failed.
final class RecentDestinationsReady extends RecentDestinationsState {
  const RecentDestinationsReady({required this.destinations});

  final List<RecentDestination> destinations;

  @override
  List<Object?> get props => [destinations];
}
