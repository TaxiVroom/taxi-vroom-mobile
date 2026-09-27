part of 'destination_search_bloc.dart';

sealed class DestinationSearchEvent extends Equatable {
  const DestinationSearchEvent();

  @override
  List<Object?> get props => [];
}

final class DestinationQueryChanged extends DestinationSearchEvent {
  const DestinationQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

final class DestinationSuggestionSelected extends DestinationSearchEvent {
  const DestinationSuggestionSelected({required this.suggestion});

  final PlaceSuggestion suggestion;

  @override
  List<Object?> get props => [suggestion];
}
