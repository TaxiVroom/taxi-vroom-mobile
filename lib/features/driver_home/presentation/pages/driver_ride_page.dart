import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/itinerary_button.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/swipe_button.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';
import 'package:mobile/features/driver_home/presentation/bloc/guidance_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/driving_map.dart';
import 'package:mobile/features/driver_home/presentation/widgets/navigation_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 7: guidance to the destination. The price is on the taxi's
/// own meter: the app cannot read it, the driver copies it at the end.
class DriverRidePage extends StatelessWidget {
  const DriverRidePage({
    required this.ride,
    required this.watchGuidanceUseCase,
    required this.onFinished,
    super.key,
  });

  final DriverRide ride;
  final WatchGuidanceUseCase watchGuidanceUseCase;
  final VoidCallback onFinished;

  // Room kept for the bottom panel when framing the route on the map.
  static const _panelHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GuidanceBloc(watchGuidanceUseCase: watchGuidanceUseCase)
            ..add(GuidanceStarted(to: ride.destination, from: ride.pickup)),
      // The ride is left through "Terminer la course" only.
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          child: BlocBuilder<GuidanceBloc, GuidanceState>(
            builder: (context, state) {
              final guidance = switch (state) {
                GuidanceReady(:final guidance) => guidance,
                _ => null,
              };
              return Stack(
                children: [
                  Positioned.fill(
                    child: DrivingMap(
                      origin: ride.pickup,
                      destination: ride.destination,
                      guidance: guidance,
                      bottomPadding: _panelHeight,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 12,
                    right: 12,
                    child: SafeArea(child: _buildTop(context, state)),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildPanel(context, guidance),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context, GuidanceState state) {
    return switch (state) {
      GuidanceLoading() => const NavigationLoadingBanner(),
      GuidanceReady(:final guidance) => NavigationBanner(guidance: guidance),
      GuidanceFailure(:final message) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: RetryMessage(
          message: message,
          onRetry: () => context.read<GuidanceBloc>().add(
            GuidanceStarted(to: ride.destination, from: ride.pickup),
          ),
        ),
      ),
    };
  }

  Widget _buildPanel(BuildContext context, Guidance? guidance) {
    return BottomPanel(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTrip(guidance),
            const SizedBox(height: 12),
            // Slid, not tapped: ending the ride by mistake right after the
            // pickup must not happen.
            SwipeButton(label: 'Terminer la course', onSwiped: onFinished),
          ],
        ),
      ),
    );
  }

  // Where to, and what is left once the road is known; "Itinéraire" leaves
  // for the driver's navigation app, as on the pickup screen.
  Widget _buildTrip(Guidance? guidance) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.destinationName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (guidance != null)
                Text(
                  '${formatDistanceMeters(guidance.metersLeft)} · '
                  '${guidance.minutesLeft} min restantes',
                  style: const TextStyle(color: AppColors.muted),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ItineraryButton(target: ride.destination),
      ],
    );
  }
}
