import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/driver/domain/entities/commune.dart';
import 'package:mobile/features/registration/driver/domain/usecases/search_communes_usecase.dart';
import 'package:stream_transform/stream_transform.dart';

part 'commune_search_event.dart';
part 'commune_search_state.dart';

// "Commune de rattachement" of "Votre taxi": the communes as the driver
// types.
class CommuneSearchBloc extends Bloc<CommuneSearchEvent, CommuneSearchState> {
  CommuneSearchBloc({required SearchCommunesUseCase searchCommunesUseCase})
    : _searchCommunesUseCase = searchCommunesUseCase,
      super(const CommuneSearchState()) {
    on<CommuneQueryChanged>(
      _onQueryChanged,
      // Waits for the driver to stop typing, and drops an older search.
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 300)).switchMap(mapper),
    );
  }

  final SearchCommunesUseCase _searchCommunesUseCase;

  Future<void> _onQueryChanged(
    CommuneQueryChanged event,
    Emitter<CommuneSearchState> emit,
  ) async {
    final query = event.query;
    emit(
      CommuneSearchState(
        query: query,
        communes: state.communes,
        isLoading: true,
      ),
    );
    switch (await _searchCommunesUseCase(query)) {
      case Ok(:final value):
        emit(CommuneSearchState(query: query, communes: value));
      case Error(:final error):
        emit(CommuneSearchState(query: query, failureMessage: error.message));
    }
  }
}
