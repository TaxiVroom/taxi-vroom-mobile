import 'package:mobile/core/domain/repositories/enterprise_contact_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/repositories/account_repository.dart';

// The "Compte" tab: the profile, and the number of "Contacter le
// développeur", asked together each time the tab opens; ready once both
// answered, failed if either failed. Specs
// taxi-vroom-api/docs/specs/compte-a-jour.md and aide-chauffeur.md.
class LoadAccountUseCase {
  const LoadAccountUseCase({
    required AccountRepository accountRepository,
    required EnterpriseContactRepository enterpriseContactRepository,
  }) : _accountRepository = accountRepository,
       _enterpriseContactRepository = enterpriseContactRepository;

  final AccountRepository _accountRepository;
  final EnterpriseContactRepository _enterpriseContactRepository;

  Future<Result<PassengerAccount>> call() async {
    final (account, contactPhone) = await (
      _accountRepository.getAccount(),
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
