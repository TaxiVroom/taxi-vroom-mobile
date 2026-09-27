import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_account_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/update_driver_notifications_usecase.dart';

part 'driver_account_event.dart';
part 'driver_account_state.dart';

/// The driver's "Compte" tab.
class DriverAccountBloc extends Bloc<DriverAccountEvent, DriverAccountState> {
  DriverAccountBloc({
    required LoadDriverAccountUseCase loadDriverAccountUseCase,
    required UpdateDriverNotificationsUseCase updateDriverNotificationsUseCase,
  }) : _loadDriverAccountUseCase = loadDriverAccountUseCase,
       _updateDriverNotificationsUseCase = updateDriverNotificationsUseCase,
       super(const DriverAccountLoading()) {
    on<DriverAccountRequested>(_onRequested);
    on<DriverAccountNotificationsToggled>(_onNotificationsToggled);
  }

  final LoadDriverAccountUseCase _loadDriverAccountUseCase;
  final UpdateDriverNotificationsUseCase _updateDriverNotificationsUseCase;

  Future<void> _onRequested(
    DriverAccountRequested event,
    Emitter<DriverAccountState> emit,
  ) async {
    emit(const DriverAccountLoading());
    switch (await _loadDriverAccountUseCase()) {
      case Ok(:final value):
        emit(
          DriverAccountReady(
            account: value.account,
            documents: value.documents,
          ),
        );
      case Error(:final error):
        emit(DriverAccountFailure(message: error.message));
    }
  }

  Future<void> _onNotificationsToggled(
    DriverAccountNotificationsToggled event,
    Emitter<DriverAccountState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverAccountReady) return;

    // The switch moves right away; it goes back if the change fails.
    emit(
      DriverAccountReady(
        account: currentState.account.withNotificationsEnabled(
          enabled: event.enabled,
        ),
        documents: currentState.documents,
      ),
    );
    final result = await _updateDriverNotificationsUseCase(
      enabled: event.enabled,
    );
    if (result case Error()) emit(currentState);
  }
}
