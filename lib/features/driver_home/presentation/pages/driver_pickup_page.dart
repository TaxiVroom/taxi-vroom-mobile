import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/itinerary_button.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';
import 'package:mobile/features/driver_home/presentation/bloc/guidance_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/driving_map.dart';
import 'package:mobile/features/driver_home/presentation/widgets/go_button.dart';
import 'package:mobile/features/driver_home/presentation/widgets/navigation_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 5: guidance to the passenger, and one button at the end.
class DriverPickupPage extends StatelessWidget {
  const DriverPickupPage({
    required this.ride,
    required this.watchGuidanceUseCase,
    required this.onArrived,
    required this.onWithdrawRequested,
    this.isSubmitting = false,
    this.failureMessage,
    super.key,
  });

  final DriverRide ride;
  final WatchGuidanceUseCase watchGuidanceUseCase;
  final VoidCallback onArrived;
  final VoidCallback onWithdrawRequested;
  final bool isSubmitting;
  final String? failureMessage;

  // Room kept for the bottom panel when framing the route on the map.
  static const _panelHeight = 330.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GuidanceBloc(watchGuidanceUseCase: watchGuidanceUseCase)
            ..add(GuidanceStarted(to: ride.pickup)),
      // The ride is left through "Je suis arrivé" or "Se désister" only.
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
                      destination: ride.pickup,
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
                    child: _buildPanel(guidance),
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
            GuidanceStarted(to: ride.pickup),
          ),
        ),
      ),
    };
  }

  Widget _buildPanel(Guidance? guidance) {
    final note = ride.customerNote;
    final failureMessage = this.failureMessage;
    return BottomPanel(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCustomer(guidance),
            if (note != null) ...[
              const SizedBox(height: 14),
              _buildNote(note),
            ],
            const SizedBox(height: 14),
            // The approach meter depends on the city's fare rules, not
            // built yet.
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lumineux rouge : vous êtes réservé.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
              ],
            ),
            if (failureMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                failureMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 14),
            GoButton.primary(
              label: 'Je suis arrivé',
              isLoading: isSubmitting,
              onPressed: onArrived,
            ),
            const SizedBox(height: 4),
            GhostButton(
              onPressed: isSubmitting ? null : onWithdrawRequested,
              alignment: Alignment.center,
              child: const Text(
                'Se désister',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Messages and calls are not built yet.
  Widget _buildCustomer(Guidance? guidance) {
    final distance = guidance == null
        ? ''
        : ', ${formatDistanceMeters(guidance.metersLeft)}';
    return Row(
      children: [
        Avatar(
          initials: Avatar.getInitials(ride.customerFullName),
          size: 48,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ride.customerFirstName} vous attend',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${ride.pickupName}$distance',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        SecondaryButton(
          density: ButtonDensity.icon,
          shape: ButtonShape.circle,
          onPressed: () {},
          child: const Icon(Icons.chat_bubble_outline),
        ),
        const SizedBox(width: 8),
        SecondaryButton(
          density: ButtonDensity.icon,
          shape: ButtonShape.circle,
          onPressed: () {},
          child: const Icon(Icons.phone_outlined),
        ),
        const SizedBox(width: 8),
        ItineraryButton(target: ride.pickup),
      ],
    );
  }

  Widget _buildNote(String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Note du client',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('« $note »', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
