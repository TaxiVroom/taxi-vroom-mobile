import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

// "Appeler" during a ride: the phone app opens on the other person's number,
// already typed (url_launcher's tel: link).
class CallPhoneUseCase {
  const CallPhoneUseCase(this._repository);

  final NavigationRepository _repository;

  Future<Result<void>> call(String phone) async {
    return switch (await _repository.open(Uri(scheme: 'tel', path: phone))) {
      Ok() => const Result.ok(null),
      Error() => const Result.error(
        DeviceFailure('Impossible d’ouvrir le téléphone.'),
      ),
    };
  }
}
