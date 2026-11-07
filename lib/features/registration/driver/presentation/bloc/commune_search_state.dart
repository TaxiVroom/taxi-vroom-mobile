part of 'commune_search_bloc.dart';

final class CommuneSearchState extends Equatable {
  const CommuneSearchState({
    this.query = '',
    this.communes = const [],
    this.isLoading = false,
    this.failureMessage,
  });

  final String query;
  final List<Commune> communes;
  final bool isLoading;
  final String? failureMessage;

  // Searched, and nothing in France matches, e.g. "London".
  bool get foundNothing =>
      query.trim().isNotEmpty &&
      !isLoading &&
      failureMessage == null &&
      communes.isEmpty;

  @override
  List<Object?> get props => [query, communes, isLoading, failureMessage];
}
