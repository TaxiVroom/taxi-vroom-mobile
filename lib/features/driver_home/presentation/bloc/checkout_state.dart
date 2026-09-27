part of 'checkout_bloc.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutReady extends CheckoutState {
  const CheckoutReady({
    required this.checkout,
    this.customerRating = 0,
    this.isSubmitting = false,
    this.failureMessage,
  });

  final RideCheckout checkout;

  // 0 means not rated yet.
  final int customerRating;

  final bool isSubmitting;

  // Why the last validation failed.
  final String? failureMessage;

  // The failure message only stays until the next change.
  CheckoutReady copyWith({
    RideCheckout? checkout,
    int? customerRating,
    bool? isSubmitting,
    String? failureMessage,
  }) => CheckoutReady(
    checkout: checkout ?? this.checkout,
    customerRating: customerRating ?? this.customerRating,
    isSubmitting: isSubmitting ?? false,
    failureMessage: failureMessage,
  );

  @override
  List<Object?> get props => [
    checkout,
    customerRating,
    isSubmitting,
    failureMessage,
  ];
}

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// Validated: the driver is free again.
final class CheckoutCompleted extends CheckoutState {
  const CheckoutCompleted();
}
