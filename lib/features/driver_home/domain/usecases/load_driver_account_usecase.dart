import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_account_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';

// The "Compte" tab: the profile, and the documents to look at any time.
class LoadDriverAccountUseCase {
  const LoadDriverAccountUseCase({
    required DriverAccountRepository driverAccountRepository,
    required DriverDocumentRepository driverDocumentRepository,
  }) : _driverAccountRepository = driverAccountRepository,
       _driverDocumentRepository = driverDocumentRepository;

  final DriverAccountRepository _driverAccountRepository;
  final DriverDocumentRepository _driverDocumentRepository;

  Future<Result<({DriverAccount account, DriverDocuments documents})>>
  call() async {
    final DriverAccount account;
    switch (await _driverAccountRepository.getAccount()) {
      case Ok(:final value):
        account = value;
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
