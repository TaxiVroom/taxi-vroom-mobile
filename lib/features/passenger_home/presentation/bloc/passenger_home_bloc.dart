import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';

part 'passenger_home_event.dart';
part 'passenger_home_state.dart';

class PassengerHomeBloc extends Bloc<PassengerHomeEvent, PassengerHomeState> {
  PassengerHomeBloc({
    required LoadPassengerHomeUseCase loadPassengerHomeUseCase,
  })  : _loadPassengerHomeUseCase = loadPassengerHomeUseCase,
        super(const PassengerHomeLoading()) {
    on<PassengerHomeStarted>(_onStarted);
  }

  final LoadPassengerHomeUseCase _loadPassengerHomeUseCase;

  Future<void> _onStarted(
    PassengerHomeStarted event,
    Emitter<PassengerHomeState> emit,
  ) async {
    emit(const PassengerHomeLoading());
    switch (await _loadPassengerHomeUseCase()) {
      case Ok(:final value):
        emit(PassengerHomeReady(home: value));
      case Error(:final error):
        emit(PassengerHomeFailure(message: error.message));
    }
  }
}
