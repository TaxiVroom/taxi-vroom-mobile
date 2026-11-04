import 'package:mobile/core/domain/repositories/push_registration_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// The ride to come back to when the app starts: null without one. The ride of
// the notification that launched the app comes first: a booked ride without
// a taxi is over before the app could ask for its current ride.
class LoadCurrentRideUseCase {
  const LoadCurrentRideUseCase({
    required RideRepository rideRepository,
    required PushRegistrationRepository pushRegistrationRepository,
  }) : _rideRepository = rideRepository,
       _pushRegistrationRepository = pushRegistrationRepository;

  final RideRepository _rideRepository;
  final PushRegistrationRepository _pushRegistrationRepository;

  Future<Result<String?>> call() async {
    final launchRideId = await _pushRegistrationRepository.getLaunchRideId();
    if (launchRideId != null) return Result.ok(launchRideId);
    return _rideRepository.getCurrentRideId();
  }
}
