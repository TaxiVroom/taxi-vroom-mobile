part of 'commune_search_bloc.dart';

sealed class CommuneSearchEvent extends Equatable {
  const CommuneSearchEvent();

  @override
  List<Object?> get props => [];
}

final class CommuneQueryChanged extends CommuneSearchEvent {
  const CommuneQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}
