import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({required LoadAccountUseCase loadAccountUseCase})
    : _loadAccountUseCase = loadAccountUseCase,
      super(const AccountLoading()) {
    on<AccountRequested>(_onRequested);
  }

  final LoadAccountUseCase _loadAccountUseCase;

  Future<void> _onRequested(
    AccountRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    switch (await _loadAccountUseCase()) {
      case Ok(:final value):
        emit(AccountReady(account: value));
      case Error(:final error):
        emit(AccountFailure(message: error.message));
    }
  }
}
