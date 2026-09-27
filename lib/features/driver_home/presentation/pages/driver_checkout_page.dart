import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/usecases/complete_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_ride_checkout_usecase.dart';
import 'package:mobile/features/driver_home/presentation/bloc/checkout_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/go_button.dart';
import 'package:mobile/features/driver_home/presentation/widgets/meter_amount_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 8: confirm the amount, and the driver is free again.
class DriverCheckoutPage extends StatelessWidget {
  const DriverCheckoutPage({
    required this.ride,
    required this.meterCents,
    required this.distanceKm,
    required this.loadRideCheckoutUseCase,
    required this.completeRideUseCase,
    required this.onCompleted,
    super.key,
  });

  final DriverRide ride;

  // Last amount read on the taximeter.
  final int meterCents;

  // Driven during the ride, according to the taximeter.
  final double distanceKm;

  final LoadRideCheckoutUseCase loadRideCheckoutUseCase;
  final CompleteRideUseCase completeRideUseCase;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(
        rideId: ride.id,
        meterCents: meterCents,
        loadRideCheckoutUseCase: loadRideCheckoutUseCase,
        completeRideUseCase: completeRideUseCase,
      )..add(const CheckoutStarted()),
      child: BlocListener<CheckoutBloc, CheckoutState>(
        listenWhen: (_, current) => current is CheckoutCompleted,
        listener: (_, _) => onCompleted(),
        // The ride is left through "Valider et repasser libre" only.
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: BlocBuilder<CheckoutBloc, CheckoutState>(
                buildWhen: (_, current) => current is! CheckoutCompleted,
                builder: (context, state) => switch (state) {
                  CheckoutLoading() || CheckoutCompleted() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  CheckoutFailure(:final message) => RetryMessage(
                    message: message,
                    onRetry: () => context.read<CheckoutBloc>().add(
                      const CheckoutStarted(),
                    ),
                  ),
                  CheckoutReady() => _buildReady(context, state),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context, CheckoutReady state) {
    final checkout = state.checkout;
    final failureMessage = state.failureMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildMeterAmount(context, checkout),
                const SizedBox(height: 14),
                _buildSupplements(context, checkout),
                const SizedBox(height: 14),
                if (checkout.paidInApp) _buildPaidInApp(checkout),
                const SizedBox(height: 10),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.receipt_long, size: 16, color: AppColors.muted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Plus de 25 € : la note de course est envoyée '
                        'automatiquement au client.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildRating(context, state),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failureMessage != null) ...[
                Text(
                  failureMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
              ],
              GoButton(
                label: 'Valider et repasser libre',
                isLoading: state.isSubmitting,
                onPressed: () => context.read<CheckoutBloc>().add(
                  const CheckoutSubmitted(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.successBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.freeTaxi),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Course terminée',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                '${ride.pickupName} → ${ride.destinationName}, '
                '${formatDistanceKm(distanceKm)}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeterAmount(BuildContext context, RideCheckout checkout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montant affiché sur le taximètre',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatEuro(checkout.meterCents),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SecondaryButton(
                density: ButtonDensity.icon,
                shape: ButtonShape.circle,
                onPressed: () => _onEditMeterAmount(context, checkout),
                child: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Relevé automatiquement. Modifiable si le taximètre affiche autre '
          'chose.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Future<void> _onEditMeterAmount(
    BuildContext context,
    RideCheckout checkout,
  ) async {
    final bloc = context.read<CheckoutBloc>();
    final meterCents = await openMeterAmountSheet(
      context,
      currentCents: checkout.meterCents,
    );
    if (meterCents != null) {
      bloc.add(CheckoutMeterAmountCorrected(meterCents: meterCents));
    }
  }

  Widget _buildSupplements(BuildContext context, RideCheckout checkout) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final supplement in checkout.supplements)
            _buildSupplement(context, checkout, supplement),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à encaisser',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formatEuro(checkout.totalCents),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplement(
    BuildContext context,
    RideCheckout checkout,
    FareSupplement supplement,
  ) {
    final count = checkout.countOf(supplement);
    void changeCount(int newCount) => context.read<CheckoutBloc>().add(
      CheckoutSupplementCountChanged(supplement: supplement, count: newCount),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplement.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
                Text(
                  '${formatEuro(supplement.amountCents)} l’unité',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          SecondaryButton(
            density: ButtonDensity.icon,
            shape: ButtonShape.circle,
            onPressed: count == 0 ? null : () => changeCount(count - 1),
            child: const Icon(Icons.remove, size: 18),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SecondaryButton(
            density: ButtonDensity.icon,
            shape: ButtonShape.circle,
            onPressed: () => changeCount(count + 1),
            child: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidInApp(RideCheckout checkout) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payé par l’application',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${checkout.paymentLabel}, rien à encaisser à bord',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.check, color: AppColors.freeTaxi),
        ],
      ),
    );
  }

  Widget _buildRating(BuildContext context, CheckoutReady state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Noter ${ride.customerFirstName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        StarRating(
          value: state.customerRating.toDouble(),
          step: 1,
          starSize: 28,
          activeColor: AppColors.star,
          onChanged: (value) => context.read<CheckoutBloc>().add(
            CheckoutCustomerRated(stars: value.round()),
          ),
        ),
      ],
    );
  }
}
