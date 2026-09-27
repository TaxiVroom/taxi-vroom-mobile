import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_receives_bookings_usecase.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc({
    required LoadDriverHomeUseCase loadDriverHomeUseCase,
    required SetOnlineUseCase setOnlineUseCase,
    required SetReceivesBookingsUseCase setReceivesBookingsUseCase,
  }) : _loadDriverHomeUseCase = loadDriverHomeUseCase,
       _setOnlineUseCase = setOnlineUseCase,
       _setReceivesBookingsUseCase = setReceivesBookingsUseCase,
       super(const DriverHomeLoading()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverOnlineToggled>(_onOnlineToggled);
    on<DriverBookingsToggled>(_onBookingsToggled);
  }

  final LoadDriverHomeUseCase _loadDriverHomeUseCase;
  final SetOnlineUseCase _setOnlineUseCase;
  final SetReceivesBookingsUseCase _setReceivesBookingsUseCase;

  Future<void> _onStarted(
    DriverHomeStarted event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(const DriverHomeLoading());
    switch (await _loadDriverHomeUseCase()) {
      case Ok(:final value):
        emit(DriverHomeReady(home: value));
      case Error(:final error):
        emit(DriverHomeFailure(message: error.message));
    }
  }

  Future<void> _onOnlineToggled(
    DriverOnlineToggled event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverHomeReady || currentState.isSwitchingOnline) {
      return;
    }

    emit(DriverHomeReady(home: currentState.home, isSwitchingOnline: true));
    final result = await _setOnlineUseCase(isOnline: event.isOnline);
    final home = currentState.home;
    emit(
      switch (result) {
        Ok() => DriverHomeReady(
          home: home.withActivity(
            home.activity.withOnline(isOnline: event.isOnline),
          ),
        ),
        Error(:final error) => DriverHomeReady(
          home: home,
          switchFailureMessage: error.message,
        ),
      },
    );
  }

  Future<void> _onBookingsToggled(
    DriverBookingsToggled event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverHomeReady) return;

    // The switch moves right away; it goes back if the change fails.
    final home = currentState.home;
    emit(
      DriverHomeReady(
        home: home.withActivity(
          home.activity.withReceivesBookings(
            receivesBookings: event.receivesBookings,
          ),
        ),
      ),
    );
    final result = await _setReceivesBookingsUseCase(
      receivesBookings: event.receivesBookings,
    );
    if (result case Error()) emit(currentState);
  }
}
