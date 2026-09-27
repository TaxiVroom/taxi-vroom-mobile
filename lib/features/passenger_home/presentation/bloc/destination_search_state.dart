part of 'destination_search_bloc.dart';

final class DestinationSearchState extends Equatable {
  const DestinationSearchState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.failureMessage,
    this.selectedDestination,
  });

  final String query;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final String? failureMessage;

  // Set once the passenger picked a suggestion: the flow moves on.
  final Place? selectedDestination;

  @override
  List<Object?> get props => [
    query,
    suggestions,
    isLoading,
    failureMessage,
    selectedDestination,
  ];
}
