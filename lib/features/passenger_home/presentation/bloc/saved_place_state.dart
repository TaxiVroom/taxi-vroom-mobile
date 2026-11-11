part of 'saved_place_bloc.dart';

sealed class SavedPlaceState extends Equatable {
  const SavedPlaceState();

  @override
  List<Object?> get props => [];
}

// The search is shown; after a failure, its message is told once.
final class SavedPlaceEditing extends SavedPlaceState {
  const SavedPlaceEditing({this.failureMessage});

  final String? failureMessage;

  @override
  List<Object?> get props => [failureMessage];
}

// The API names the point and keeps it: a loader meanwhile.
final class SavedPlaceSaving extends SavedPlaceState {
  const SavedPlaceSaving();
}

final class SavedPlaceDeleting extends SavedPlaceState {
  const SavedPlaceDeleting();
}

final class SavedPlaceSaved extends SavedPlaceState {
  const SavedPlaceSaved({required this.place});

  final SavedPlace place;

  @override
  List<Object?> get props => [place];
}

final class SavedPlaceDeleted extends SavedPlaceState {
  const SavedPlaceDeleted({required this.kind});

  final SavedPlaceKind kind;

  @override
  List<Object?> get props => [kind];
}
