import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_recent_destinations_usecase.dart';

part 'recent_destinations_event.dart';
part 'recent_destinations_state.dart';

// The recent destinations of "Votre trajet", read each time it opens. Spec
// taxi-vroom-api/docs/specs/destinations-recentes.md.
class RecentDestinationsBloc
    extends Bloc<RecentDestinationsEvent, RecentDestinationsState> {
  RecentDestinationsBloc({
    required LoadRecentDestinationsUseCase loadRecentDestinationsUseCase,
  }) : _loadRecentDestinationsUseCase = loadRecentDestinationsUseCase,
       super(const RecentDestinationsLoading()) {
    on<RecentDestinationsRequested>(_onRequested);
  }

  final LoadRecentDestinationsUseCase _loadRecentDestinationsUseCase;

  // A failure shows nothing: the search still works without them.
  Future<void> _onRequested(
    RecentDestinationsRequested event,
    Emitter<RecentDestinationsState> emit,
  ) async {
    emit(const RecentDestinationsLoading());
    emit(
      RecentDestinationsReady(
        destinations: switch (await _loadRecentDestinationsUseCase()) {
          Ok(:final value) => value,
          Error() => const [],
        },
      ),
    );
  }
}
