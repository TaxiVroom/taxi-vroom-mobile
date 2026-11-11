import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/delete_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_account_usecase.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required LoadAccountUseCase loadAccountUseCase,
    required DeleteSavedPlaceUseCase deleteSavedPlaceUseCase,
  }) : _loadAccountUseCase = loadAccountUseCase,
       _deleteSavedPlaceUseCase = deleteSavedPlaceUseCase,
       super(const AccountLoading()) {
    on<AccountRequested>(_onRequested);
    on<AccountSavedPlaceDeleteRequested>(_onSavedPlaceDeleteRequested);
  }

  final LoadAccountUseCase _loadAccountUseCase;
  final DeleteSavedPlaceUseCase _deleteSavedPlaceUseCase;

  Future<void> _onRequested(
    AccountRequested event,
    Emitter<AccountState> emit,
  ) async {
    // The loader each time the tab opens, until the API answers (decision of
    // the user, 2026-11-11).
    emit(const AccountLoading());
    switch (await _loadAccountUseCase()) {
      case Ok(:final value):
        emit(AccountReady(account: value));
      case Error(:final error):
        emit(AccountFailure(message: error.message));
    }
  }

  // Straight from the list, without confirmation. Spec
  // taxi-vroom-api/docs/specs/maison-et-travail.md.
  Future<void> _onSavedPlaceDeleteRequested(
    AccountSavedPlaceDeleteRequested event,
    Emitter<AccountState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountReady) return;
    final account = currentState.account;

    emit(AccountReady(account: account, deletingKind: event.kind));
    emit(switch (await _deleteSavedPlaceUseCase(event.kind)) {
      Ok() => AccountReady(
        account: account.withoutSavedPlace(event.kind),
        deletedKind: event.kind,
      ),
      Error(:final error) => AccountReady(
        account: account,
        failureMessage: error.message,
      ),
    });
  }
}
