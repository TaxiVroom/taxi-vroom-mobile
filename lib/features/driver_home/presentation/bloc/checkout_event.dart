part of 'checkout_bloc.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

// The screen is shown, or the driver taps "Réessayer".
final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted();
}

// The driver copied the amount shown on the taxi's meter.
final class CheckoutMeterAmountEntered extends CheckoutEvent {
  const CheckoutMeterAmountEntered({required this.meterCents});

  final int meterCents;

  @override
  List<Object?> get props => [meterCents];
}

// The − or + of a supplement.
final class CheckoutSupplementCountChanged extends CheckoutEvent {
  const CheckoutSupplementCountChanged({
    required this.supplement,
    required this.count,
  });

  final FareSupplement supplement;
  final int count;

  @override
  List<Object?> get props => [supplement, count];
}

final class CheckoutCustomerRated extends CheckoutEvent {
  const CheckoutCustomerRated({required this.stars});

  // 1 to 5.
  final int stars;

  @override
  List<Object?> get props => [stars];
}

// "Valider et repasser libre".
final class CheckoutSubmitted extends CheckoutEvent {
  const CheckoutSubmitted();
}
