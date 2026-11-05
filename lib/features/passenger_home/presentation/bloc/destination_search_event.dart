part of 'destination_search_bloc.dart';

sealed class DestinationSearchEvent extends Equatable {
  const DestinationSearchEvent();

  @override
  List<Object?> get props => [];
}

// The passenger moved to another field: its own suggestions come next.
final class DestinationSearchFieldFocused extends DestinationSearchEvent {
  const DestinationSearchFieldFocused({required this.field});

  final SearchField field;

  @override
  List<Object?> get props => [field];
}

// What the passenger typed in the active field.
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
