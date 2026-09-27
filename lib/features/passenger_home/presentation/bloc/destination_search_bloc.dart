import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/domain/usecases/select_destination_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/suggest_destinations_usecase.dart';
import 'package:stream_transform/stream_transform.dart';

part 'destination_search_event.dart';
part 'destination_search_state.dart';

class DestinationSearchBloc
    extends Bloc<DestinationSearchEvent, DestinationSearchState> {
  DestinationSearchBloc({
    required Coordinates origin,
    required SuggestDestinationsUseCase suggestDestinationsUseCase,
    required SelectDestinationUseCase selectDestinationUseCase,
  }) : _origin = origin,
       _suggestDestinationsUseCase = suggestDestinationsUseCase,
       _selectDestinationUseCase = selectDestinationUseCase,
       super(const DestinationSearchState()) {
    on<DestinationQueryChanged>(
      _onQueryChanged,
      transformer: _debounceLatest(const Duration(milliseconds: 300)),
    );
    on<DestinationSuggestionSelected>(_onSuggestionSelected);
  }

  final Coordinates _origin;
  final SuggestDestinationsUseCase _suggestDestinationsUseCase;
  final SelectDestinationUseCase _selectDestinationUseCase;

  // Waits for the passenger to stop typing, and drops an ongoing search
  // when a newer query arrives.
  static EventTransformer<E> _debounceLatest<E>(Duration duration) =>
      (events, mapper) => events.debounce(duration).switchMap(mapper);

  Future<void> _onQueryChanged(
    DestinationQueryChanged event,
    Emitter<DestinationSearchState> emit,
  ) async {
    emit(
      DestinationSearchState(
        query: event.query,
        suggestions: state.suggestions,
        isLoading: true,
      ),
    );
    switch (await _suggestDestinationsUseCase(
      query: event.query,
      near: _origin,
    )) {
      case Ok(:final value):
        emit(DestinationSearchState(query: event.query, suggestions: value));
      case Error(:final error):
        emit(
          DestinationSearchState(
            query: event.query,
            failureMessage: error.message,
          ),
        );
    }
  }

  Future<void> _onSuggestionSelected(
    DestinationSuggestionSelected event,
    Emitter<DestinationSearchState> emit,
  ) async {
    emit(
      DestinationSearchState(
        query: state.query,
        suggestions: state.suggestions,
        isLoading: true,
      ),
    );
    switch (await _selectDestinationUseCase(event.suggestion)) {
      case Ok(:final value):
        emit(
          DestinationSearchState(
            query: state.query,
            suggestions: state.suggestions,
            selectedDestination: value,
          ),
        );
      case Error(:final error):
        emit(
          DestinationSearchState(
            query: state.query,
            suggestions: state.suggestions,
            failureMessage: error.message,
          ),
        );
    }
  }
}
