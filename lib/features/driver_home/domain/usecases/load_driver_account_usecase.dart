import 'package:mobile/core/domain/repositories/enterprise_contact_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_account_repository.dart';

// The "Compte" tab: profile, vehicle and documents, and the number of
// "Contacter le développeur", asked together each time the tab opens; ready
// once both answered, failed if either failed. Specs
// taxi-vroom-api/docs/specs/compte-a-jour.md and aide-chauffeur.md.
class LoadDriverAccountUseCase {
  const LoadDriverAccountUseCase({
    required DriverAccountRepository driverAccountRepository,
    required EnterpriseContactRepository enterpriseContactRepository,
  }) : _driverAccountRepository = driverAccountRepository,
       _enterpriseContactRepository = enterpriseContactRepository;

  final DriverAccountRepository _driverAccountRepository;
  final EnterpriseContactRepository _enterpriseContactRepository;

  Future<Result<DriverAccount>> call() async {
    final (account, contactPhone) = await (
      _driverAccountRepository.getAccount(),
      _enterpriseContactRepository.getPhone(),
    ).wait;
    return switch ((account, contactPhone)) {
      (Ok(value: final account), Ok(value: final phone)) => Result.ok(
        account.withContactPhone(phone),
      ),
      (Error(:final error), _) || (_, Error(:final error)) => Result.error(
        error,
      ),
    };
  }
}
