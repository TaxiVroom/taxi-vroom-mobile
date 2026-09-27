import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/usecases/complete_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_ride_checkout_usecase.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

/// Mockup screen 8: the driver confirms the amount, adds the supplements and
/// rates the passenger.
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required String rideId,
    required int meterCents,
    required LoadRideCheckoutUseCase loadRideCheckoutUseCase,
    required CompleteRideUseCase completeRideUseCase,
  }) : _rideId = rideId,
       _meterCents = meterCents,
       _loadRideCheckoutUseCase = loadRideCheckoutUseCase,
       _completeRideUseCase = completeRideUseCase,
       super(const CheckoutLoading()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutMeterAmountCorrected>(_onMeterAmountCorrected);
    on<CheckoutSupplementCountChanged>(_onSupplementCountChanged);
    on<CheckoutCustomerRated>(_onCustomerRated);
    on<CheckoutSubmitted>(_onSubmitted);
  }

  final String _rideId;
  final int _meterCents;
  final LoadRideCheckoutUseCase _loadRideCheckoutUseCase;
  final CompleteRideUseCase _completeRideUseCase;

  Future<void> _onStarted(
    CheckoutStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());
    final result = await _loadRideCheckoutUseCase(
      rideId: _rideId,
      meterCents: _meterCents,
    );
    emit(
      switch (result) {
        Ok(:final value) => CheckoutReady(checkout: value),
        Error(:final error) => CheckoutFailure(message: error.message),
      },
    );
  }

  void _onMeterAmountCorrected(
    CheckoutMeterAmountCorrected event,
    Emitter<CheckoutState> emit,
  ) {
    final currentState = state;
    if (currentState is! CheckoutReady) return;
    emit(
      currentState.copyWith(
        checkout: currentState.checkout.withMeterCents(event.meterCents),
      ),
    );
  }

  void _onSupplementCountChanged(
    CheckoutSupplementCountChanged event,
    Emitter<CheckoutState> emit,
  ) {
    final currentState = state;
    if (currentState is! CheckoutReady) return;
    emit(
      currentState.copyWith(
        checkout: currentState.checkout.withCount(
          event.supplement,
          event.count,
        ),
      ),
    );
  }

  void _onCustomerRated(
    CheckoutCustomerRated event,
    Emitter<CheckoutState> emit,
  ) {
    final currentState = state;
    if (currentState is! CheckoutReady) return;
    emit(currentState.copyWith(customerRating: event.stars));
  }

  Future<void> _onSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CheckoutReady || currentState.isSubmitting) return;

    emit(currentState.copyWith(isSubmitting: true));
    final result = await _completeRideUseCase(
      rideId: _rideId,
      checkout: currentState.checkout,
      customerRating: currentState.customerRating,
    );
    emit(
      switch (result) {
        Ok() => const CheckoutCompleted(),
        Error(:final error) => currentState.copyWith(
          failureMessage: error.message,
        ),
      },
    );
  }
}
