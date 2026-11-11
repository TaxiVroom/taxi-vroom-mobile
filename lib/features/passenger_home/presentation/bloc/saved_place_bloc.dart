import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/add_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/change_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/delete_saved_place_usecase.dart';

part 'saved_place_event.dart';
part 'saved_place_state.dart';

// The screen of one "Maison" or "Travail": saves the place chosen, or
// deletes it. Spec taxi-vroom-api/docs/specs/maison-et-travail.md.
class SavedPlaceBloc extends Bloc<SavedPlaceEvent, SavedPlaceState> {
  SavedPlaceBloc({
    required SavedPlaceKind kind,
    required bool isSaved,
    required AddSavedPlaceUseCase addSavedPlaceUseCase,
    required ChangeSavedPlaceUseCase changeSavedPlaceUseCase,
    required DeleteSavedPlaceUseCase deleteSavedPlaceUseCase,
  }) : _kind = kind,
       _isSaved = isSaved,
       _addSavedPlaceUseCase = addSavedPlaceUseCase,
       _changeSavedPlaceUseCase = changeSavedPlaceUseCase,
       _deleteSavedPlaceUseCase = deleteSavedPlaceUseCase,
       super(const SavedPlaceEditing()) {
    on<SavedPlaceChosen>(_onChosen);
    on<SavedPlaceDeleteRequested>(_onDeleteRequested);
  }

  final SavedPlaceKind _kind;

  // Already saved: the point chosen changes it, otherwise adds it.
  final bool _isSaved;
  final AddSavedPlaceUseCase _addSavedPlaceUseCase;
  final ChangeSavedPlaceUseCase _changeSavedPlaceUseCase;
  final DeleteSavedPlaceUseCase _deleteSavedPlaceUseCase;

  Future<void> _onChosen(
    SavedPlaceChosen event,
    Emitter<SavedPlaceState> emit,
  ) async {
    emit(const SavedPlaceSaving());
    final result = _isSaved
        ? await _changeSavedPlaceUseCase(_kind, event.place)
        : await _addSavedPlaceUseCase(_kind, event.place);
    emit(switch (result) {
      Ok(:final value) => SavedPlaceSaved(place: value),
      Error(:final error) => SavedPlaceEditing(failureMessage: error.message),
    });
  }

  Future<void> _onDeleteRequested(
    SavedPlaceDeleteRequested event,
    Emitter<SavedPlaceState> emit,
  ) async {
    emit(const SavedPlaceDeleting());
    emit(switch (await _deleteSavedPlaceUseCase(_kind)) {
      Ok() => SavedPlaceDeleted(kind: _kind),
      Error(:final error) => SavedPlaceEditing(failureMessage: error.message),
    });
  }
}
