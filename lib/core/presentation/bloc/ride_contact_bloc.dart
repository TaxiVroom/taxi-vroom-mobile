import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/call_phone_usecase.dart';
import 'package:mobile/core/domain/usecases/message_phone_usecase.dart';
import 'package:mobile/core/utils/result.dart';

part 'ride_contact_event.dart';
part 'ride_contact_state.dart';

// "Appeler" and "Écrire" during a ride, on both sides: the phone or messages
// app opens on the other person's number, and a link that cannot open is
// told.
class RideContactBloc extends Bloc<RideContactEvent, RideContactState> {
  RideContactBloc({
    required CallPhoneUseCase callPhoneUseCase,
    required MessagePhoneUseCase messagePhoneUseCase,
  }) : _callPhoneUseCase = callPhoneUseCase,
       _messagePhoneUseCase = messagePhoneUseCase,
       super(const RideContactState()) {
    on<RideContactCalled>(_onCalled);
    on<RideContactMessaged>(_onMessaged);
  }

  final CallPhoneUseCase _callPhoneUseCase;
  final MessagePhoneUseCase _messagePhoneUseCase;

  Future<void> _onCalled(
    RideContactCalled event,
    Emitter<RideContactState> emit,
  ) async => _emitFailure(await _callPhoneUseCase(event.phone), emit);

  Future<void> _onMessaged(
    RideContactMessaged event,
    Emitter<RideContactState> emit,
  ) async => _emitFailure(await _messagePhoneUseCase(event.phone), emit);

  void _emitFailure(Result<void> result, Emitter<RideContactState> emit) {
    if (result case Error(:final error)) {
      emit(
        RideContactState(
          failures: state.failures + 1,
          failureMessage: error.message,
        ),
      );
    }
  }
}
