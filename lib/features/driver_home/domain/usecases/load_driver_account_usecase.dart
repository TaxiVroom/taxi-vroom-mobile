import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_account_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_vehicle_repository.dart';

// The "Compte" tab: the profile with the real vehicle, and the documents to
// look at any time.
class LoadDriverAccountUseCase {
  const LoadDriverAccountUseCase({
    required DriverAccountRepository driverAccountRepository,
    required DriverVehicleRepository driverVehicleRepository,
    required DriverDocumentRepository driverDocumentRepository,
  }) : _driverAccountRepository = driverAccountRepository,
       _driverVehicleRepository = driverVehicleRepository,
       _driverDocumentRepository = driverDocumentRepository;

  final DriverAccountRepository _driverAccountRepository;
  final DriverVehicleRepository _driverVehicleRepository;
  final DriverDocumentRepository _driverDocumentRepository;

  Future<Result<({DriverAccount account, DriverDocuments documents})>>
  call() async {
    final DriverAccount profile;
    switch (await _driverAccountRepository.getAccount()) {
      case Ok(:final value):
        profile = value;
      case Error(:final error):
        return Result.error(error);
    }

    final DriverAccount account;
    switch (await _driverVehicleRepository.getVehicle()) {
      case Ok(:final value):
        account = profile.withVehicle(value);
      case Error(:final error):
        return Result.error(error);
    }

    final DriverDocuments documents;
    switch (await _driverDocumentRepository.getDocuments()) {
      case Ok(:final value):
        documents = value;
      case Error(:final error):
        return Result.error(error);
    }

    return Result.ok((account: account, documents: documents));
  }
}
