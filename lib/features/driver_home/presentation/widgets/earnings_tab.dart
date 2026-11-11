import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/retry_message.dart';
import 'package:mobile/features/driver_home/domain/entities/earnings.dart';
import 'package:mobile/features/driver_home/presentation/bloc/earnings_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The "Gains" tab: spec taxi-vroom-api/docs/specs/gains-du-chauffeur.md.
class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});

  static const _plotHeight = 120.0;
  static const _labelHeight = 20.0;
  // Room above the top mark, so its label and line are not cut.
  static const _topMargin = 10.0;
  static const _axisWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(context, state.period),
            const SizedBox(height: 14),
            switch (state) {
              EarningsLoading() => const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              ),
              EarningsFailure(:final message) => RetryMessage(
                message: message,
                onRetry: () =>
                    context.read<EarningsBloc>().add(const EarningsRequested()),
              ),
              EarningsReady(:final earnings, :final pickedDay) =>
                _buildEarnings(context, earnings, pickedDay),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EarningsPeriod period) {
    final bloc = context.read<EarningsBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Gains',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        // The menu opens under the button that was tapped.
        Builder(
          builder: (buttonContext) => OutlineButton(
            onPressed: () => showDropdown<void>(
              context: buttonContext,
              builder: (_) => DropdownMenu(
                children: [
                  MenuRadioGroup<EarningsPeriod>(
                    value: period,
                    onChanged: (_, chosen) =>
                        bloc.add(EarningsPeriodChosen(chosen)),
                    children: [
                      for (final choice in EarningsPeriod.values)
                        MenuRadio(
                          value: choice,
                          child: Text(_periodLabel(choice)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.expand_more, size: 18),
            child: Text(_periodLabel(period)),
          ),
        ),
      ],
    );
  }

  String _periodLabel(EarningsPeriod period) => switch (period) {
    EarningsPeriod.today => "Aujourd'hui",
    EarningsPeriod.week => 'Cette semaine',
    EarningsPeriod.month => 'Ce mois',
  };

  Widget _buildEarnings(
    BuildContext context,
    Earnings earnings,
    DateTime? pickedDay,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatEuro(earnings.totalCents),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
        ),
        // Every ride is paid on board: the money is already with the driver.
        // No online hours: the API does not know when a driver goes offline.
        Text(
          '${earnings.rideCount} courses, encaissé à bord (carte ou espèces)',
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        // A single day has no chart.
        if (earnings.period != EarningsPeriod.today) ...[
          const SizedBox(height: 16),
          _buildPickedDay(earnings, pickedDay),
          const SizedBox(height: 4),
          _buildChart(context, earnings, pickedDay),
        ],
      ],
    );
  }

  // "Mardi 10 nov. : 95,10 €" once a bar is tapped.
  Widget _buildPickedDay(Earnings earnings, DateTime? pickedDay) {
    const style = TextStyle(fontSize: 13, color: AppColors.muted);
    final picked = earnings.days
        .where((day) => day.day == pickedDay)
        .firstOrNull;
    if (picked == null) {
      return const Text(
        'Touchez une barre pour voir le montant du jour.',
        style: style,
      );
    }
    return Text.rich(
      TextSpan(
        text: '${formatLongDate(picked.day)} : ',
        children: [
          TextSpan(
            text: formatEuro(picked.amountCents),
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: style,
    );
  }

  // The euro axis on the left, one bar per day, today in the ink color.
  Widget _buildChart(
    BuildContext context,
    Earnings earnings,
    DateTime? pickedDay,
  ) {
    final top = earnings.axisTopCents;
    final marksCents = [0, top ~/ 2, top];
    final today = DateTime.now();
    final isMonth = earnings.period == EarningsPeriod.month;
    return SizedBox(
      height: _topMargin + _plotHeight + _labelHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _axisWidth,
            child: Stack(
              children: [
                for (final markCents in marksCents)
                  Positioned(
                    right: 6,
                    bottom: _markBottom(markCents, top) - 6,
                    child: Text(
                      formatWholeEuro(markCents),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                for (final markCents in marksCents)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _markBottom(markCents, top),
                    child: Container(height: 1, color: AppColors.border),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in earnings.days)
                      Expanded(
                        child: _buildBar(
                          context,
                          day,
                          share: earnings.shareOfAxis(day),
                          label: isMonth
                              ? _monthDayLabel(day.day)
                              : formatShortWeekday(day.day),
                          isToday: DateUtils.isSameDay(day.day, today),
                          isPicked: day.day == pickedDay,
                          gap: isMonth ? 1 : 4,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _markBottom(int markCents, int topCents) =>
      _labelHeight + _plotHeight * markCents / topCents;

  // The date under one bar out of seven: 1, 8, 15, 22, 29.
  String _monthDayLabel(DateTime day) =>
      (day.day - 1) % 7 == 0 ? '${day.day}' : '';

  Widget _buildBar(
    BuildContext context,
    DayEarnings day, {
    required double share,
    required String label,
    required bool isToday,
    required bool isPicked,
    required double gap,
  }) {
    // Today stays in the ink color, even when tapped.
    final color = switch ((isToday, isPicked)) {
      (true, _) => AppColors.ink,
      (false, true) => AppColors.muted,
      (false, false) => AppColors.border,
    };
    return GestureDetector(
      // The whole column is tappable, even above a short or empty bar.
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<EarningsBloc>().add(EarningsDayTapped(day.day)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: _plotHeight * share,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                  bottom: Radius.circular(2),
                ),
              ),
            ),
            SizedBox(
              height: _labelHeight,
              // A month label is wider than its thin bar.
              child: OverflowBox(
                maxWidth: 40,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.ink : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
