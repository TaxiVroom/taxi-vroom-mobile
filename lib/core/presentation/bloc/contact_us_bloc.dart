import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/call_enterprise_usecase.dart';
import 'package:mobile/core/utils/result.dart';

part 'contact_us_event.dart';
part 'contact_us_state.dart';

// "Nous contacter" in both "Compte" tabs. Spec
// taxi-vroom-api/docs/specs/aide-chauffeur.md.
class ContactUsBloc extends Bloc<ContactUsEvent, ContactUsState> {
  ContactUsBloc({required CallEnterpriseUseCase callEnterpriseUseCase})
    : _callEnterpriseUseCase = callEnterpriseUseCase,
      super(const ContactUsState()) {
    on<ContactUsCalled>(_onCalled);
  }

  final CallEnterpriseUseCase _callEnterpriseUseCase;

  Future<void> _onCalled(
    ContactUsCalled event,
    Emitter<ContactUsState> emit,
  ) async {
    // A tap while the number is coming does nothing more.
    if (state.isCalling) return;
    emit(
      ContactUsState(
        isCalling: true,
        failures: state.failures,
        failureMessage: state.failureMessage,
      ),
    );
    switch (await _callEnterpriseUseCase(knownPhone: event.knownPhone)) {
      case Ok():
        emit(
          ContactUsState(
            failures: state.failures,
            failureMessage: state.failureMessage,
          ),
        );
      case Error(:final error):
        emit(
          ContactUsState(
            failures: state.failures + 1,
            failureMessage: error.message,
          ),
        );
    }
  }
}
