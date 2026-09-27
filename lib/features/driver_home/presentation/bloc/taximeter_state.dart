part of 'taximeter_bloc.dart';

sealed class TaximeterState extends Equatable {
  const TaximeterState();

  @override
  List<Object?> get props => [];
}

// No reading from the meter yet.
final class TaximeterWaiting extends TaximeterState {
  const TaximeterWaiting();
}

final class TaximeterRunning extends TaximeterState {
  const TaximeterRunning({required this.reading});

  final MeterReading reading;

  @override
  List<Object?> get props => [reading];
}

final class TaximeterFailure extends TaximeterState {
  const TaximeterFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
