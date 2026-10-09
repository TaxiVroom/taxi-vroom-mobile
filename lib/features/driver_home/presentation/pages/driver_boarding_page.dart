import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';
import 'package:mobile/features/driver_home/presentation/bloc/boarding_bloc.dart';
import 'package:mobile/features/driver_home/presentation/widgets/go_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 6: the boarding code starts the ride.
class DriverBoardingPage extends StatelessWidget {
  const DriverBoardingPage({
    required this.ride,
    required this.arrivedAt,
    required this.startRideUseCase,
    required this.reportNoShowUseCase,
    required this.withdrawFromRideUseCase,
    required this.onRideStarted,
    required this.onNoShowReported,
    required this.onWithdrawn,
    super.key,
  });

  final DriverRide ride;
  final DateTime arrivedAt;
  final StartRideUseCase startRideUseCase;
  final ReportNoShowUseCase reportNoShowUseCase;
  final WithdrawFromRideUseCase withdrawFromRideUseCase;
  final VoidCallback onRideStarted;
  final VoidCallback onNoShowReported;
  final VoidCallback onWithdrawn;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BoardingBloc(
        rideId: ride.id,
        arrivedAt: arrivedAt,
        startRideUseCase: startRideUseCase,
        reportNoShowUseCase: reportNoShowUseCase,
        withdrawFromRideUseCase: withdrawFromRideUseCase,
      )..add(const BoardingWaitStarted()),
      child: BlocListener<BoardingBloc, BoardingState>(
        listener: (context, state) => switch (state) {
          BoardingRideStarted() => onRideStarted(),
          BoardingNoShowReported() => onNoShowReported(),
          BoardingWithdrawn() => onWithdrawn(),
          BoardingInProgress() => null,
        },
        // The ride is left through "Démarrer la course", "Client absent" or
        // "Se désister".
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<BoardingBloc, BoardingState>(
                  buildWhen: (_, current) => current is BoardingInProgress,
                  builder: (context, state) => switch (state) {
                    BoardingInProgress() => _buildContent(context, state),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BoardingInProgress state) {
    final failureMessage = state.failureMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWaiting(state),
        const SizedBox(height: 14),
        const Text(
          'Code de montée',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Demandez à ${ride.customerFirstName} les '
          '${StartRideUseCase.codeLength} chiffres affichés dans '
          'son app.',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        _buildCode(state),
        const SizedBox(height: 8),
        _buildCodeStatus(state),
        if (failureMessage != null)
          Text(
            failureMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        const SizedBox(height: 14),
        _buildKeypad(context),
        const Spacer(),
        GoButton(
          label: 'Démarrer la course',
          isLoading: state.isSubmitting,
          onPressed: state.canStart
              ? () => context.read<BoardingBloc>().add(
                  const BoardingRideStartRequested(),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: GhostButton(
                onPressed: state.isSubmitting || !state.canReportNoShow
                    ? null
                    : () => context.read<BoardingBloc>().add(
                        const BoardingNoShowRequested(),
                      ),
                alignment: Alignment.center,
                child: Text(
                  _noShowLabel(state),
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            ),
            Expanded(
              child: GhostButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => context.read<BoardingBloc>().add(
                        const BoardingWithdrawRequested(),
                      ),
                alignment: Alignment.center,
                child: const Text(
                  'Se désister',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // "Client absent dans 3:12" until the driver waited long enough.
  String _noShowLabel(BoardingInProgress state) {
    final left = ReportNoShowUseCase.waitLeft(waited: state.waited);
    return left == Duration.zero
        ? 'Client absent'
        : 'Client absent dans ${formatWaitingTime(left)}';
  }

  // "Attente 1:12" and who the driver waits for.
  Widget _buildWaiting(BoardingInProgress state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 6),
              Text(
                'Attente ${formatWaitingTime(state.waited)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${ride.customerFirstName}, ${ride.pickupName}',
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildCode(BoardingInProgress state) {
    final borderColor = switch (state.codeStatus) {
      BoardingCodeStatus.incorrect ||
      BoardingCodeStatus.locked => AppColors.danger,
      BoardingCodeStatus.typing => null,
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < StartRideUseCase.codeLength; i++)
          Container(
            width: 56,
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              i < state.code.length ? state.code[i] : '',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }

  Widget _buildCodeStatus(BoardingInProgress state) {
    final attemptsLeft = state.attemptsLeft;
    final plural = attemptsLeft > 1 ? 's' : '';
    final (text, color) = switch (state.codeStatus) {
      BoardingCodeStatus.incorrect => (
        'Code incorrect, vérifiez avec votre client '
            '($attemptsLeft essai$plural restant$plural)',
        AppColors.danger,
      ),
      BoardingCodeStatus.locked => (
        'Trop de codes incorrects : appelez votre client ou désistez-vous',
        AppColors.danger,
      ),
      BoardingCodeStatus.typing => ('', AppColors.muted),
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  // 1 to 9, then 0 and the erase key on the last row.
  Widget _buildKeypad(BuildContext context) {
    final bloc = context.read<BoardingBloc>();
    Widget key(Widget label, VoidCallback onPressed) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: SizedBox(
          height: 46,
          child: SecondaryButton(
            onPressed: onPressed,
            alignment: Alignment.center,
            child: label,
          ),
        ),
      ),
    );
    Widget digit(int value) => key(
      Text(
        '$value',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      () => bloc.add(BoardingDigitPressed(digit: value)),
    );
    return Column(
      children: [
        for (final row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final value in row) digit(value)]),
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            digit(0),
            key(
              const Icon(Icons.backspace_outlined),
              () => bloc.add(const BoardingDigitErased()),
            ),
          ],
        ),
      ],
    );
  }
}
