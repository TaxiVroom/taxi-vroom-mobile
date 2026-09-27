import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/update_notifications_usecase.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required LoadAccountUseCase loadAccountUseCase,
    required UpdateNotificationsUseCase updateNotificationsUseCase,
  }) : _loadAccountUseCase = loadAccountUseCase,
       _updateNotificationsUseCase = updateNotificationsUseCase,
       super(const AccountLoading()) {
    on<AccountRequested>(_onRequested);
    on<AccountNotificationsToggled>(_onNotificationsToggled);
  }

  final LoadAccountUseCase _loadAccountUseCase;
  final UpdateNotificationsUseCase _updateNotificationsUseCase;

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

  Future<void> _onNotificationsToggled(
    AccountNotificationsToggled event,
    Emitter<AccountState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountReady) return;

    // The switch moves right away; it goes back if the change fails.
    emit(
      AccountReady(
        account: currentState.account.withNotificationsEnabled(event.enabled),
      ),
    );
    final result = await _updateNotificationsUseCase(enabled: event.enabled);
    if (result case Error()) emit(currentState);
  }
}
