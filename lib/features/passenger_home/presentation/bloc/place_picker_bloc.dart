import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:stream_transform/stream_transform.dart';

part 'place_picker_event.dart';
part 'place_picker_state.dart';

// "Choisir sur la carte" and "Confirmer le point de prise en charge": the
// place under the pin, each time the map stops. Spec
// point-de-prise-en-charge.md.
class PlacePickerBloc extends Bloc<PlacePickerEvent, PlacePickerState> {
  PlacePickerBloc({required FindPlaceAtUseCase findPlaceAtUseCase})
    : _findPlaceAtUseCase = findPlaceAtUseCase,
      super(const PlacePickerState()) {
    on<PlacePickerCenterChanged>(
      _onCenterChanged,
      // The map moved again: the address of where it was is dropped.
      transformer: (events, mapper) => events.switchMap(mapper),
    );
  }

  final FindPlaceAtUseCase _findPlaceAtUseCase;

  Future<void> _onCenterChanged(
    PlacePickerCenterChanged event,
    Emitter<PlacePickerState> emit,
  ) async {
    emit(PlacePickerState(place: state.place, isLoading: true));
    emit(PlacePickerState(place: await _findPlaceAtUseCase(event.center)));
  }
}
