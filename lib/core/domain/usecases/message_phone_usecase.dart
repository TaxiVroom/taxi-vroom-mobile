import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

// "Écrire" during a ride: the messages app opens on a new message to the
// other person's number (url_launcher's sms: link).
class MessagePhoneUseCase {
  const MessagePhoneUseCase(this._repository);

  final NavigationRepository _repository;

  Future<Result<void>> call(String phone) async {
    return switch (await _repository.open(Uri(scheme: 'sms', path: phone))) {
      Ok() => const Result.ok(null),
      Error() => const Result.error(
        DeviceFailure('Impossible d’ouvrir les messages.'),
      ),
    };
  }
}
