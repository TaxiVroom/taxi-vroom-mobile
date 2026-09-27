part of 'taximeter_bloc.dart';

sealed class TaximeterEvent extends Equatable {
  const TaximeterEvent();

  @override
  List<Object?> get props => [];
}

// The ride started: the meter runs.
final class TaximeterStarted extends TaximeterEvent {
  const TaximeterStarted();
}
