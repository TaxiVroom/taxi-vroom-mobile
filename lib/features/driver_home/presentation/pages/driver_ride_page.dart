import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/core/widgets/taxi_meter.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/meter_reading.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_taximeter_usecase.dart';
import 'package:mobile/features/driver_home/presentation/bloc/guidance_bloc.dart';
import 'package:mobile/features/driver_home/presentation/bloc/taximeter_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/driving_map.dart';
import 'package:mobile/features/driver_home/presentation/widgets/go_button.dart';
import 'package:mobile/features/driver_home/presentation/widgets/navigation_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 7: guidance to the destination, and the meter, which is
/// the legal price.
class DriverRidePage extends StatelessWidget {
  const DriverRidePage({
    required this.ride,
    required this.watchGuidanceUseCase,
    required this.watchTaximeterUseCase,
    required this.onFinished,
    super.key,
  });

  final DriverRide ride;
  final WatchGuidanceUseCase watchGuidanceUseCase;
  final WatchTaximeterUseCase watchTaximeterUseCase;
  // With the last meter reading, null if the meter never answered.
  final ValueChanged<MeterReading?> onFinished;

  // Room kept for the bottom panel when framing the route on the map.
  static const _panelHeight = 360.0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GuidanceBloc(watchGuidanceUseCase: watchGuidanceUseCase)
                ..add(GuidanceStarted(to: ride.destination, from: ride.pickup)),
        ),
        BlocProvider(
          create: (_) =>
              TaximeterBloc(watchTaximeterUseCase: watchTaximeterUseCase)
                ..add(const TaximeterStarted()),
        ),
      ],
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
      GuidanceLoading() => const SizedBox.shrink(),
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
            _buildMeter(guidance),
            const SizedBox(height: 12),
            // Supplements and the safety tools are not built yet.
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: () {},
                    alignment: Alignment.center,
                    leading: const Icon(Icons.add, size: 18),
                    child: const Text('Supplément'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    onPressed: () {},
                    alignment: Alignment.center,
                    leading: const Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    child: const Text(
                      'Sécurité',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GoButton.primary(
              label: 'Terminer la course',
              onPressed: () => onFinished(
                switch (context.read<TaximeterBloc>().state) {
                  TaximeterRunning(:final reading) => reading,
                  _ => null,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeter(Guidance? guidance) {
    return BlocBuilder<TaximeterBloc, TaximeterState>(
      builder: (context, state) => switch (state) {
        TaximeterRunning(:final reading) => TaxiMeter(
          tariff: reading.tariff,
          amountCents: reading.amountCents,
          caption: 'Taximètre connecté',
          detail: ride.destinationName,
          trailingDetail: guidance == null
              ? null
              : formatDistanceMeters(guidance.metersLeft),
        ),
        TaximeterWaiting() => const Center(
          child: CircularProgressIndicator(),
        ),
        TaximeterFailure(:final message) => Text(
          message,
          style: const TextStyle(color: AppColors.muted),
        ),
      },
    );
  }
}
