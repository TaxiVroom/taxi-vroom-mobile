import 'package:mobile/core/domain/repositories/enterprise_contact_repository.dart';
import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

// "Nous contacter": asks the API for the number, then opens the phone app on
// it, already typed (url_launcher's tel: link). Any failure, from the API or
// the phone, is told the same way. Spec taxi-vroom-api/docs/specs/
// aide-chauffeur.md.
class CallEnterpriseUseCase {
  const CallEnterpriseUseCase({
    required EnterpriseContactRepository enterpriseContactRepository,
    required NavigationRepository navigationRepository,
  }) : _enterpriseContactRepository = enterpriseContactRepository,
       _navigationRepository = navigationRepository;

  final EnterpriseContactRepository _enterpriseContactRepository;
  final NavigationRepository _navigationRepository;

  static const _notCalled = DeviceFailure('Impossible d’ouvrir le téléphone.');

  // [knownPhone]: the number already received, e.g. by the driver's "Compte"
  // tab when it opened; the API is then not asked again.
  Future<Result<void>> call({String? knownPhone}) async {
    final String phone;
    switch (knownPhone != null
        ? Result.ok(knownPhone)
        : await _enterpriseContactRepository.getPhone()) {
      case Ok(:final value):
        phone = value;
      case Error():
        return const Result.error(_notCalled);
    }
    return switch (await _navigationRepository.open(
      Uri(scheme: 'tel', path: phone),
    )) {
      Ok() => const Result.ok(null),
      Error() => const Result.error(_notCalled),
    };
  }
}
