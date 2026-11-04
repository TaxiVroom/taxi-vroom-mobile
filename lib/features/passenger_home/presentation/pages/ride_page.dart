import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/license_plate.dart';
import 'package:mobile/core/widgets/map_pill.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/ride_map.dart';
import 'package:mobile/features/passenger_home/domain/entities/driver.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/vehicle.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/passenger_flow_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_bloc.dart';
import 'package:mobile/features/passenger_home/presentation/bloc/ride_history_bloc.dart';
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
        listener: (context, state) {
          if (state is RideEnded && state.isRatingLost) {
            showMessageToast(
              context,
              title: 'Note non envoyée',
              message: 'Votre note n’a pas pu être envoyée.',
            );
          }
          // "Mes courses" changed: a booking left "À venir", or a ride
          // joined "Passées".
          context.read<RideHistoryBloc>().add(const RideHistoryRequested());
          context.read<PassengerFlowBloc>().add(const PassengerRideEnded());
        },
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
                    onFinished: ({required stars, required compliments}) =>
                        context.read<RideBloc>().add(
                          RideRatingSubmitted(
                            stars: stars,
                            compliments: compliments,
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
      RideDriverArrived() => 'Votre taxi est arrivé',
      RideInProgress(:final estimatedArrival?) =>
        'Arrivée vers ${formatClockTime(estimatedArrival)}',
      _ => null,
    };
    // Once in the taxi, the ride can't be cancelled from the app anymore.
    final canCancel = switch (ride) {
      RideSearchingDriver() ||
      RideDriverApproaching() ||
      RideDriverArrived() => true,
      _ => false,
    };
    return Stack(
      children: [
        Positioned.fill(
          child: RideMap(
            origin: origin,
            bottomPadding: _panelHeight,
            remainingRoute: remainingRoute?.path,
            driverPosition: switch (ride) {
              RideDriverApproaching(:final driverPosition) ||
              RideDriverArrived(:final driverPosition) => driverPosition,
              RideInProgress(:final taxiPosition) => taxiPosition,
              _ => null,
            },
            destination: ride is RideInProgress ? ride.destination : null,
            // In the taxi, the taxi marker alone shows where the passenger
            // is: two GPS never quite agree.
            showsDevicePosition: ride is! RideInProgress,
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
                  RideNoDriverFound() => _buildStopped(
                    context,
                    title: 'Aucun taxi disponible',
                    text:
                        'Les taxis autour de vous sont occupés. Réessayez '
                        'dans quelques minutes.',
                  ),
                  RideCancelled() => _buildStopped(
                    context,
                    title: 'Course annulée',
                    text: 'Vous avez annulé cette course.',
                  ),
                  RidePassengerNoShow() => _buildStopped(
                    context,
                    title: 'Votre chauffeur ne vous a pas trouvé',
                    text:
                        'Il vous a attendu au point de prise en charge, '
                        'puis a dû repartir.',
                  ),
                  RideDriverApproaching() => _buildApproaching(ride),
                  RideDriverArrived() => _buildDriverComing(
                    title:
                        '${_firstName(ride.driver)} vous attend au point '
                        'de prise en charge',
                    driver: ride.driver,
                    vehicle: ride.vehicle,
                    boardingCode: ride.boardingCode,
                  ),
                  RideInProgress() => _buildInProgress(ride, remainingRoute),
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

  // The ride stopped without the passenger: they can only go back.
  Widget _buildStopped(
    BuildContext context, {
    required String title,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 12),
        PrimaryButton(
          onPressed: () => context.read<RideBloc>().add(const RideLeft()),
          alignment: Alignment.center,
          child: const Text('Retour'),
        ),
      ],
    );
  }

  String _firstName(Driver driver) => driver.name.split(' ').first;

  Widget _buildApproaching(RideDriverApproaching ride) {
    final firstName = _firstName(ride.driver);
    final etaMinutes = ride.etaMinutes;
    return _buildDriverComing(
      title: etaMinutes == null
          ? '$firstName est en route'
          : '$firstName arrive dans $etaMinutes min',
      driver: ride.driver,
      vehicle: ride.vehicle,
      boardingCode: ride.boardingCode,
    );
  }

  // The taxi to look for, and the code to give its driver.
  Widget _buildDriverComing({
    required String title,
    required Driver driver,
    required Vehicle vehicle,
    required String boardingCode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        Text(
          '${vehicle.model} ${vehicle.color}',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        LicensePlate(plate: vehicle.plate, department: vehicle.department),
        const SizedBox(height: 12),
        DriverSummary(driver: driver),
        const SizedBox(height: 12),
        _buildBoardingCode(boardingCode),
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

  // The meter is not connected yet: the price estimated when ordering.
  Widget _buildInProgress(RideInProgress ride, RideRoute? remainingRoute) {
    final estimate = formatEuroRange(ride.minPriceCents, ride.maxPriceCents);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'En route vers votre destination',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        Text(
          [
            'Estimation $estimate',
            if (remainingRoute != null)
              '${formatDistanceKm(remainingRoute.distanceKm)} restants',
          ].join(' · '),
          style: const TextStyle(color: AppColors.muted),
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
