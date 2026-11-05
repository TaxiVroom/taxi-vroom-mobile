part of 'destination_search_bloc.dart';

// The field of "Votre trajet" being typed in.
enum SearchField { pickup, destination }

final class DestinationSearchState extends Equatable {
  const DestinationSearchState({
    this.activeField = SearchField.destination,
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.failureMessage,
    this.selectedPickup,
    this.selectedDestination,
  });

  // The suggestions are for this field.
  final SearchField activeField;
  final String query;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final String? failureMessage;

  // Set once the passenger picked a suggestion for the pickup: the flow
  // keeps it, and the destination is asked next.
  final Place? selectedPickup;

  // Set once the passenger picked a suggestion: the flow moves on.
  final Place? selectedDestination;

  @override
  List<Object?> get props => [
    activeField,
    query,
    suggestions,
    isLoading,
    failureMessage,
    selectedPickup,
    selectedDestination,
  ];
}
