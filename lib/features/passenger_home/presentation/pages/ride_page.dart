import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/license_plate.dart';
import 'package:mobile/core/widgets/map_pill.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/ride_map.dart';
import 'package:mobile/core/widgets/taxi_meter.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/driver_summary.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/ride_completed_view.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Follows an ordered ride: searching for a taxi, taxi approaching (mockup
/// screen 7), in the taxi (screen 8), then the end of the ride (screen 9).
class RidePage extends StatelessWidget {
  const RidePage({
    required this.rideId,
    required this.origin,
    required this.watchRideUseCase,
    required this.cancelRideUseCase,
    required this.rateRideUseCase,
    super.key,
  });

  final String rideId;
  final Coordinates origin;
  final WatchRideUseCase watchRideUseCase;
  final CancelRideUseCase cancelRideUseCase;
  final RateRideUseCase rateRideUseCase;

  // Room kept for the bottom panel when framing the route on the map.
  static const _panelHeight = 340.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RideBloc(
        rideId: rideId,
        watchRideUseCase: watchRideUseCase,
        cancelRideUseCase: cancelRideUseCase,
        rateRideUseCase: rateRideUseCase,
      )..add(const RideStarted()),
      child: BlocListener<RideBloc, RideState>(
        listenWhen: (_, current) => current is RideEnded,
        listener: (context, _) =>
            context.read<PassengerFlowBloc>().add(const PassengerRideEnded()),
        // An ordered ride is left through "Annuler la course" or "Terminer".
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            child: BlocBuilder<RideBloc, RideState>(
              builder: (context, state) => switch (state) {
                RideLoading() || RideEnded() => const Center(
                  child: CircularProgressIndicator(),
                ),
                RideFailure(:final message) => RetryMessage(
                  message: message,
                  onRetry: () =>
                      context.read<RideBloc>().add(const RideStarted()),
                ),
                RideTracking(
                  ride: final RideCompleted ride,
                  :final isSubmitting,
                ) =>
                  RideCompletedView(
                    ride: ride,
                    isSubmitting: isSubmitting,
                    onFinished:
                        ({
                          required stars,
                          required compliments,
                          required tipCents,
                        }) => context.read<RideBloc>().add(
                          RideRatingSubmitted(
                            stars: stars,
                            compliments: compliments,
                            tipCents: tipCents,
                          ),
                        ),
                  ),
                RideTracking(
                  :final ride,
                  :final remainingRoute,
                  :final isSubmitting,
                ) =>
                  _buildOnMap(
                    context,
                    ride,
                    remainingRoute: remainingRoute,
                    isSubmitting: isSubmitting,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnMap(
    BuildContext context,
    Ride ride, {
    required RideRoute? remainingRoute,
    required bool isSubmitting,
  }) {
    final pill = switch (ride) {
      RideDriverApproaching(:final etaMinutes?) =>
        'Arrive dans $etaMinutes min',
      RideInProgress(:final estimatedArrival) =>
        'Arrivée vers ${formatClockTime(estimatedArrival)}',
      _ => null,
    };
    // Once in the taxi, the ride can't be cancelled from the app anymore.
    final canCancel =
        ride is RideSearchingDriver || ride is RideDriverApproaching;
    return Stack(
      children: [
        Positioned.fill(
          child: RideMap(
            origin: origin,
            bottomPadding: _panelHeight,
            remainingRoute: remainingRoute?.path,
            driverPosition: switch (ride) {
              RideDriverApproaching(:final driverPosition) => driverPosition,
              RideInProgress(:final taxiPosition) => taxiPosition,
              _ => null,
            },
            destination: ride is RideInProgress ? ride.destination : null,
          ),
        ),
        if (pill != null)
          Positioned(
            top: 0,
            left: 16,
            child: SafeArea(child: MapPill(text: pill)),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                switch (ride) {
                  RideSearchingDriver() => _buildSearching(),
                  RideNoDriverFound() => _buildNoDriverFound(context),
                  RideDriverApproaching() => _buildApproaching(ride),
                  RideInProgress() => _buildInProgress(ride),
                  // Shown full screen, never on the map.
                  RideCompleted() => const SizedBox.shrink(),
                },
                if (canCancel) ...[
                  const SizedBox(height: 12),
                  DestructiveButton(
                    onPressed: isSubmitting
                        ? null
                        : () => context.read<RideBloc>().add(
                            const RideCancelRequested(),
                          ),
                    alignment: Alignment.center,
                    child: const Text('Annuler la course'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearching() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
            SizedBox(width: 12),
            Text(
              'Recherche d’un taxi…',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Nous prévenons les taxis libres autour de vous.',
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildNoDriverFound(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Aucun taxi disponible',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Les taxis autour de vous sont occupés. Réessayez dans quelques '
          'minutes.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          onPressed: () => context.read<RideBloc>().add(const RideLeft()),
          alignment: Alignment.center,
          child: const Text('Retour'),
        ),
      ],
    );
  }

  Widget _buildApproaching(RideDriverApproaching ride) {
    final firstName = ride.driver.name.split(' ').first;
    final etaMinutes = ride.etaMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etaMinutes == null
              ? '$firstName est en route'
              : '$firstName arrive dans $etaMinutes min',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        Text(
          '${ride.vehicle.model} ${ride.vehicle.color}',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        LicensePlate(
          plate: ride.vehicle.plate,
          department: ride.vehicle.department,
        ),
        const SizedBox(height: 12),
        DriverSummary(driver: ride.driver),
        const SizedBox(height: 12),
        _buildBoardingCode(ride.boardingCode),
        const SizedBox(height: 12),
        // Calling, messaging and sharing the ride are not built yet.
        _buildActions(const [
          (Icons.phone_outlined, 'Appeler'),
          (Icons.chat_bubble_outline, 'Écrire'),
          (Icons.ios_share, 'Partager'),
        ]),
      ],
    );
  }

  Widget _buildInProgress(RideInProgress ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaxiMeter(
          tariff: ride.tariff,
          amountCents: ride.meterCents,
          caption: 'Compteur',
          detail: '${formatDistanceKm(ride.remainingKm)} restants',
        ),
        const SizedBox(height: 12),
        DriverSummary(driver: ride.driver),
        const SizedBox(height: 12),
        // Sharing the trip and the safety tools are not built yet.
        _buildActions(const [
          (Icons.ios_share, 'Partager le trajet'),
          (Icons.shield_outlined, 'Sécurité'),
        ]),
      ],
    );
  }

  Widget _buildBoardingCode(String boardingCode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code de montée',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'À donner au chauffeur',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          for (final digit in boardingCode.split(''))
            Container(
              width: 32,
              height: 40,
              margin: const EdgeInsets.only(left: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(List<(IconData, String)> actions) {
    return Row(
      children: [
        for (final (index, (icon, label)) in actions.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: OutlineButton(
              onPressed: () {},
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(height: 4),
                  Text(label, maxLines: 1),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
