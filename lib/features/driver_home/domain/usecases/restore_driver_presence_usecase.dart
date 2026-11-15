import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';

// At start, without a ride: the driver's entry left in Firebase (an app
// restarted while online) puts them back online, the same way as "Passer en
// ligne"; when that cannot be done, the entry is removed so no passenger sees
// a taxi that is not there. Spec
// taxi-vroom-api/docs/specs/presence-du-chauffeur-au-demarrage.md.
//
// Ok(true): back online. Ok(false): offline, nothing to tell. Error: offline,
// the entry removed, and why.
class RestoreDriverPresenceUseCase {
  const RestoreDriverPresenceUseCase({
    required DriverRideRepository driverRideRepository,
    required DriverPresenceRepository driverPresenceRepository,
    required SetOnlineUseCase setOnlineUseCase,
  }) : _driverRideRepository = driverRideRepository,
       _driverPresenceRepository = driverPresenceRepository,
       _setOnlineUseCase = setOnlineUseCase;

  final DriverRideRepository _driverRideRepository;
  final DriverPresenceRepository _driverPresenceRepository;
  final SetOnlineUseCase _setOnlineUseCase;

  // [mayGoOnline] is false when the home could not load (no position): the
  // driver stays offline whatever the entry says.
  Future<Result<bool>> call({required bool mayGoOnline}) async {
    switch (await _driverRideRepository.getCurrentRide()) {
      // A ride is resumed elsewhere, back online with it: never touched here.
      case Ok(value: _?):
        return const Result.ok(false);
      // Maybe in a ride: marking the taxi free would be wrong.
      case Error(:final error):
        return _offline(error);
      case Ok():
        break;
    }
    if (!mayGoOnline) {
      await _driverPresenceRepository.goOffline();
      return const Result.ok(false);
    }

    final bool isPresent;
    switch (await _driverPresenceRepository.hasPresence()) {
      case Ok(:final value):
        isPresent = value;
      case Error(:final error):
        return _offline(error);
    }
    if (!isPresent) return const Result.ok(false);

    return switch (await _setOnlineUseCase(isOnline: true)) {
      Ok() => const Result.ok(true),
      Error(:final error) => _offline(error),
    };
  }

  Future<Result<bool>> _offline(Failure error) async {
    await _driverPresenceRepository.goOffline();
    return Result.error(error);
  }
}
