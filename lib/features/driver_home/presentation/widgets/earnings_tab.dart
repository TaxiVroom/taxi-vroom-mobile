import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';
import 'package:mobile/features/driver_home/presentation/bloc/earnings_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 10: the week at a glance.
class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});

  static const _chartHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) => switch (state) {
          EarningsLoading() => const Center(child: CircularProgressIndicator()),
          EarningsFailure(:final message) => RetryMessage(
            message: message,
            onRetry: () =>
                context.read<EarningsBloc>().add(const EarningsRequested()),
          ),
          EarningsReady(:final earnings) => _buildEarnings(earnings),
        },
      ),
    );
  }

  Widget _buildEarnings(WeeklyEarnings earnings) {
    final onlineHours = earnings.onlineMinutes ~/ 60;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Choosing another week is not built yet.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gains',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            OutlineButton(
              onPressed: () {},
              trailing: const Icon(Icons.expand_more, size: 18),
              child: const Text('Cette semaine'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          formatEuro(earnings.totalCents),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
        ),
        // Every ride is paid on board: the money is already with the driver.
        Text(
          '${earnings.rideCount} courses, $onlineHours h en ligne, encaissé à '
          'bord (carte ou espèces)',
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        _buildChart(earnings),
        const SizedBox(height: 16),
        // The PDF statement is not built yet.
        PlaceListTile(
          icon: Icons.receipt_long,
          title: 'Relevé de la semaine',
          subtitle: 'PDF pour votre comptabilité',
          onPressed: () {},
          trailing: const Icon(Icons.download_outlined),
        ),
      ],
    );
  }

  // One bar per day, today in the ink color.
  Widget _buildChart(WeeklyEarnings earnings) {
    final today = DateTime.now();
    return SizedBox(
      height: _chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final day in earnings.days)
            Expanded(
              child: _buildBar(
                day,
                share: earnings.shareOfBestDay(day),
                isToday: DateUtils.isSameDay(day.day, today),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBar(
    DayEarnings day, {
    required double share,
    required bool isToday,
  }) {
    const labelHeight = 20.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: (_chartHeight - labelHeight) * share,
            decoration: BoxDecoration(
              color: isToday ? AppColors.ink : AppColors.border,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
                bottom: Radius.circular(3),
              ),
            ),
          ),
          SizedBox(
            height: labelHeight,
            child: Center(
              child: Text(
                formatShortWeekday(day.day),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? AppColors.ink : AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
