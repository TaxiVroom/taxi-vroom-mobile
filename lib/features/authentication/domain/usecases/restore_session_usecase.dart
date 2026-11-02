import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/authentication/domain/repositories/auth_repository.dart';

// The role of the user still signed in on this phone: null means going
// through the sign-in screens.
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserRole?> call() => _repository.findSessionRole();
}
