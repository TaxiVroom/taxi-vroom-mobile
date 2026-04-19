import 'package:mobile/core/domain/repositories/email_availability_repository.dart';

class CheckEmailAvailabilityUseCase {
  const CheckEmailAvailabilityUseCase(this._repository);
  final EmailAvailabilityRepository _repository;
  Future<bool> call({required String email}) =>
      _repository.checkEmailAvailability(email: email);
}
