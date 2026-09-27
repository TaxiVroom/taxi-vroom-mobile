import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/repositories/account_repository.dart';

class LoadAccountUseCase {
  const LoadAccountUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<PassengerAccount>> call() => _repository.getAccount();
}
