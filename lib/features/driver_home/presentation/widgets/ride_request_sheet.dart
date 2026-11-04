import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/rating_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:mobile/features/driver_home/presentation/bloc/ride_request_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/go_button.dart';
import 'package:mobile/features/driver_home/presentation/widgets/trip_stops.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Opens mockup screen 4 over the map. It closes itself once the request is
/// accepted, declined or expired.
Future<void> openRideRequestSheet(BuildContext context) {
  final bloc = context.read<RideRequestBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: const RideRequestSheet(),
    ),
  );
}

/// Everything to decide in 3 seconds, and one tap to accept.
class RideRequestSheet extends StatelessWidget {
  const RideRequestSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Answering goes through the buttons, or the countdown.
      canPop: false,
      child: BlocConsumer<RideRequestBloc, RideRequestState>(
        listenWhen: (_, current) => current is! RideRequestOffered,
        listener: (context, _) => Navigator.of(context).pop(),
        buildWhen: (_, current) => current is RideRequestOffered,
        builder: (context, state) => switch (state) {
          RideRequestOffered() => _buildCard(context, state),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, RideRequestOffered state) {
    final failureMessage = state.failureMessage;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(state),
            const SizedBox(height: 14),
            _buildTrip(state.offer),
            const SizedBox(height: 14),
            _buildCustomer(state.offer.request),
            const SizedBox(height: 14),
            GoButton(
              label: 'Accepter la course',
              isLoading: state.isResponding,
              onPressed: () => context.read<RideRequestBloc>().add(
                const RideRequestAccepted(),
              ),
            ),
            if (failureMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                failureMessage,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: state.isResponding
                  ? null
                  : () => context.read<RideRequestBloc>().add(
                      const RideRequestDeclined(),
                    ),
              alignment: Alignment.center,
              child: const Text('Refuser'),
            ),
          ],
        ),
      ),
    );
  }

  // "Réservation pour 11:56": the passenger booked, and waits at that time.
  String _kindLabel(DateTime? scheduledPickup) => scheduledPickup == null
      ? 'Course immédiate'
      : 'Réservation pour ${formatClockTime(scheduledPickup)}';

  Widget _buildHeader(RideRequestOffered state) {
    final request = state.offer.request;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _kindLabel(request.scheduledPickup),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              Text(
                formatEuroRange(request.minPriceCents, request.maxPriceCents),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'estimé au compteur, ${formatDistanceKm(request.distanceKm)}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        _buildCountdown(state.secondsLeft),
      ],
    );
  }

  Widget _buildCountdown(int secondsLeft) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: secondsLeft / RideRequest.responseTime.inSeconds,
            size: 58,
            strokeWidth: 4,
            color: AppColors.freeTaxi,
            backgroundColor: AppColors.border,
          ),
          Text(
            '$secondsLeft',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildTrip(RoutedRideRequest offer) {
    final request = offer.request;
    final approach = offer.approach;
    final trip = offer.trip;
    return TripStops(
      pickupName: request.pickupName,
      pickupDetail: approach == null
          ? null
          : 'Prise en charge à ${formatDistanceKm(approach.distanceKm)}, '
                '${approach.durationMinutes} min',
      destinationName: request.destinationName,
      destinationDetail: trip == null
          ? null
          : 'Environ ${trip.durationMinutes} min de trajet',
    );
  }

  Widget _buildCustomer(RideRequest request) {
    final passengers = request.passengerCount > 1
        ? '${request.passengerCount} passagers'
        : '${request.passengerCount} passager';
    final luggage = request.luggageCount > 1
        ? '${request.luggageCount} bagages'
        : '${request.luggageCount} bagage';
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildChip(
          '${request.customerFirstName} '
          '${formatRating(request.customerRating)}',
          icon: Icons.star,
        ),
        _buildChip(passengers),
        _buildChip(luggage),
      ],
    );
  }

  Widget _buildChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.star),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
