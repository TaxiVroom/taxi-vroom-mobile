import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_activity_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';

// "Passer en ligne" / "Passer hors ligne": the driver appears at their
// position for passengers and the backend, or disappears. Going online is
// first allowed by the API, which checks the documents. Spec
// taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 8.
class SetOnlineUseCase {
  const SetOnlineUseCase({
    required LocationRepository locationRepository,
    required DriverPresenceRepository driverPresenceRepository,
    required DriverActivityRepository driverActivityRepository,
    required DriverDocumentRepository driverDocumentRepository,
  }) : _locationRepository = locationRepository,
       _driverPresenceRepository = driverPresenceRepository,
       _driverActivityRepository = driverActivityRepository,
       _driverDocumentRepository = driverDocumentRepository;

  final LocationRepository _locationRepository;
  final DriverPresenceRepository _driverPresenceRepository;
  final DriverActivityRepository _driverActivityRepository;
  final DriverDocumentRepository _driverDocumentRepository;

  Future<Result<void>> call({required bool isOnline}) async {
    final Result<void> presence;
    if (isOnline) {
      final allowed = await _driverDocumentRepository.allowOnline();
      if (allowed case Error(:final error)) return Result.error(error);
      final Coordinates position;
      switch (await _locationRepository.getCurrentPosition()) {
        case Ok(:final value):
          position = value;
        case Error(:final error):
          return Result.error(error);
      }
      presence = await _driverPresenceRepository.goOnline(position);
    } else {
      presence = await _driverPresenceRepository.goOffline();
    }
    if (presence case Error(:final error)) return Result.error(error);

    return _driverActivityRepository.setOnline(isOnline: isOnline);
  }
}
