import 'package:equatable/equatable.dart';

/// The server's answer to "Démarrer la course": it checks the boarding code
/// and starts the ride at once.
sealed class RideStart extends Equatable {
  const RideStart();

  @override
  List<Object?> get props => [];
}

final class RideStartAccepted extends RideStart {
  const RideStartAccepted();
}

final class RideStartWrongCode extends RideStart {
  const RideStartWrongCode({required this.attemptsLeft});

  final int attemptsLeft;

  @override
  List<Object?> get props => [attemptsLeft];
}

// Too many wrong codes: the driver calls the passenger or cancels.
final class RideStartLocked extends RideStart {
  const RideStartLocked();
}
