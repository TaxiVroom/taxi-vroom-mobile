part of 'boarding_bloc.dart';

sealed class BoardingEvent extends Equatable {
  const BoardingEvent();

  @override
  List<Object?> get props => [];
}

// The screen is shown: the waiting time starts counting.
final class BoardingWaitStarted extends BoardingEvent {
  const BoardingWaitStarted();
}

final class BoardingDigitPressed extends BoardingEvent {
  const BoardingDigitPressed({required this.digit});

  // 0 to 9.
  final int digit;

  @override
  List<Object?> get props => [digit];
}

final class BoardingDigitErased extends BoardingEvent {
  const BoardingDigitErased();
}

// "Démarrer la course".
final class BoardingRideStartRequested extends BoardingEvent {
  const BoardingRideStartRequested();
}

// "Client absent".
final class BoardingNoShowRequested extends BoardingEvent {
  const BoardingNoShowRequested();
}

// One second of waiting went by.
final class _BoardingTicked extends BoardingEvent {
  const _BoardingTicked();
}
