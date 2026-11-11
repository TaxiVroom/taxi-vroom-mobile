import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_account_usecase.dart';

part 'driver_account_event.dart';
part 'driver_account_state.dart';

/// The driver's "Compte" tab.
class DriverAccountBloc extends Bloc<DriverAccountEvent, DriverAccountState> {
  DriverAccountBloc({
    required LoadDriverAccountUseCase loadDriverAccountUseCase,
  }) : _loadDriverAccountUseCase = loadDriverAccountUseCase,
       super(const DriverAccountLoading()) {
    on<DriverAccountRequested>(_onRequested);
  }

  final LoadDriverAccountUseCase _loadDriverAccountUseCase;

  Future<void> _onRequested(
    DriverAccountRequested event,
    Emitter<DriverAccountState> emit,
  ) async {
    // The loader each time the tab opens, until the API answers (decision of
    // the user, 2026-11-11).
    emit(const DriverAccountLoading());
    switch (await _loadDriverAccountUseCase()) {
      case Ok(:final value):
        emit(DriverAccountReady(account: value));
      case Error(:final error):
        emit(DriverAccountFailure(message: error.message));
    }
  }
}
