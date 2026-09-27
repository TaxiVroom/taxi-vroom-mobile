import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';

// Everything the "Mes courses" tab shows.
class RideHistory extends Equatable {
  const RideHistory({required this.upcoming, required this.past});

  // Soonest first.
  final List<BookedRide> upcoming;

  // Most recent first.
  final List<PastRide> past;

  @override
  List<Object?> get props => [upcoming, past];
}
