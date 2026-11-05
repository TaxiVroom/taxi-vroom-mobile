import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_app.dart';
import 'package:mobile/core/domain/usecases/open_navigation_usecase.dart';
import 'package:mobile/core/utils/result.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

// "Itinéraire" on the pickup and ride screens: the app chosen in the sheet
// opens, and a link that cannot open is told. Spec navigation-externe.md.
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc({required OpenNavigationUseCase openNavigationUseCase})
    : _openNavigationUseCase = openNavigationUseCase,
      super(const NavigationState()) {
    on<NavigationOpened>(_onOpened);
  }

  final OpenNavigationUseCase _openNavigationUseCase;

  Future<void> _onOpened(
    NavigationOpened event,
    Emitter<NavigationState> emit,
  ) async {
    final result = await _openNavigationUseCase(event.app, event.target);
    if (result case Error(:final error)) {
      emit(
        NavigationState(
          failures: state.failures + 1,
          failureMessage: error.message,
        ),
      );
    }
  }
}
