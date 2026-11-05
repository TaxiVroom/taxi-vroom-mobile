part of 'place_picker_bloc.dart';

sealed class PlacePickerEvent extends Equatable {
  const PlacePickerEvent();

  @override
  List<Object?> get props => [];
}

// The map stopped, its center under the pin; also when the screen opens.
final class PlacePickerCenterChanged extends PlacePickerEvent {
  const PlacePickerCenterChanged({required this.center});

  final Coordinates center;

  @override
  List<Object?> get props => [center];
}
