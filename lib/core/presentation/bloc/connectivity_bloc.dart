import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

// Whether the device is connected to Firebase, for the whole signed-in app:
// the banner at the top of every screen tells when it is not.
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc({required WatchConnectionUseCase watchConnectionUseCase})
    : _watchConnectionUseCase = watchConnectionUseCase,
      super(const ConnectivityState()) {
    on<ConnectivityWatchStarted>(_onWatchStarted);
  }

  final WatchConnectionUseCase _watchConnectionUseCase;

  Future<void> _onWatchStarted(
    ConnectivityWatchStarted event,
    Emitter<ConnectivityState> emit,
  ) => emit.forEach<bool>(
    _watchConnectionUseCase(),
    onData: (isConnected) => ConnectivityState(isConnected: isConnected),
  );
}
