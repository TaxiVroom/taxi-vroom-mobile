part of 'place_picker_bloc.dart';

final class PlacePickerState extends Equatable {
  const PlacePickerState({this.place, this.isLoading = false});

  // Null until the first address came back.
  final Place? place;

  // The address of a new center is on its way: it can't be confirmed yet.
  final bool isLoading;

  @override
  List<Object?> get props => [place, isLoading];
}
