import 'package:mobile/core/domain/repositories/enterprise_contact_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/repositories/account_repository.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';

// The "Compte" tab: the profile, "Maison" and "Travail", and the number of
// "Contacter le développeur", asked together each time the tab opens; ready
// once all answered, failed if any failed. Specs
// taxi-vroom-api/docs/specs/compte-a-jour.md, aide-chauffeur.md and
// maison-et-travail.md.
class LoadAccountUseCase {
  const LoadAccountUseCase({
    required AccountRepository accountRepository,
    required SavedPlaceRepository savedPlaceRepository,
    required EnterpriseContactRepository enterpriseContactRepository,
  }) : _accountRepository = accountRepository,
       _savedPlaceRepository = savedPlaceRepository,
       _enterpriseContactRepository = enterpriseContactRepository;

  final AccountRepository _accountRepository;
  final SavedPlaceRepository _savedPlaceRepository;
  final EnterpriseContactRepository _enterpriseContactRepository;

  Future<Result<PassengerAccount>> call() async {
    final (account, savedPlaces, contactPhone) = await (
      _accountRepository.getAccount(),
      _savedPlaceRepository.getSavedPlaces(),
      _enterpriseContactRepository.getPhone(),
    ).wait;
    return switch ((account, savedPlaces, contactPhone)) {
      (
        Ok(value: final account),
        Ok(value: final places),
        Ok(value: final phone),
      ) =>
        Result.ok(account.complete(savedPlaces: places, contactPhone: phone)),
      (Error(:final error), _, _) ||
      (_, Error(:final error), _) ||
      (_, _, Error(:final error)) => Result.error(error),
    };
  }
}
