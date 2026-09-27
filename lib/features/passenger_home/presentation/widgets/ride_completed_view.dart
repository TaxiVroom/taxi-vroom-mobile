import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/core/widgets/section_label.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 9: total and meter breakdown, then rating the driver and an
/// optional tip.
class RideCompletedView extends StatefulWidget {
  const RideCompletedView({
    required this.ride,
    required this.isSubmitting,
    required this.onFinished,
    super.key,
  });

  final RideCompleted ride;
  final bool isSubmitting;
  final void Function({
    required int stars,
    required List<String> compliments,
    required int tipCents,
  })
  onFinished;

  @override
  State<RideCompletedView> createState() => _RideCompletedViewState();
}

class _RideCompletedViewState extends State<RideCompletedView> {
  static const _compliments = ['Conduite douce', 'Ponctuel', 'Aide bagages'];
  static const _tipsCents = [0, 100, 200, 500];

  // 0 star means the passenger did not rate the ride.
  int _stars = 0;
  final Set<String> _selectedCompliments = {};
  int _tipCents = 0;

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final firstName = ride.driver.name.split(' ').first;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildArrival(ride),
            const SizedBox(height: 16),
            Text(
              formatEuro(ride.totalCents),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
            ),
            // No payment in the app yet: the passenger pays the driver.
            const Text(
              'À régler au chauffeur',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            _buildFareBreakdown(ride),
            const SizedBox(height: 24),
            Text(
              'Comment s’est passée la course avec $firstName ?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildStars(),
            const SizedBox(height: 8),
            _buildCompliments(),
            const SizedBox(height: 16),
            const SectionLabel('Pourboire (facultatif)'),
            _buildTips(),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: widget.isSubmitting ? null : _onFinished,
              alignment: Alignment.center,
              child: const Text('Terminer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrival(RideCompleted ride) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 40, color: AppColors.freeTaxi),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vous êtes arrivé',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                '${ride.destinationName}, ${formatClockTime(ride.arrivedAt)}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareBreakdown(RideCompleted ride) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final line in ride.fareLines)
            _buildFareRow(line.label, line.amountCents),
          const Divider(),
          _buildFareRow('Total au compteur', ride.totalCents, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, int amountCents, {bool isTotal = false}) {
    final style = isTotal
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle(color: AppColors.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatEuro(amountCents), style: style),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Align(
      alignment: Alignment.centerLeft,
      child: StarRating(
        value: _stars.toDouble(),
        step: 1,
        starSize: 36,
        activeColor: AppColors.star,
        onChanged: (value) => setState(() => _stars = value.round()),
      ),
    );
  }

  Widget _buildCompliments() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final compliment in _compliments)
          ChoiceButton(
            label: compliment,
            isSelected: _selectedCompliments.contains(compliment),
            onPressed: () => setState(() {
              if (!_selectedCompliments.remove(compliment)) {
                _selectedCompliments.add(compliment);
              }
            }),
          ),
      ],
    );
  }

  Widget _buildTips() {
    return Wrap(
      spacing: 8,
      children: [
        for (final tipCents in _tipsCents)
          ChoiceButton(
            label: tipCents == 0 ? 'Aucun' : '${tipCents ~/ 100} €',
            isSelected: tipCents == _tipCents,
            onPressed: () => setState(() => _tipCents = tipCents),
          ),
      ],
    );
  }

  void _onFinished() {
    widget.onFinished(
      stars: _stars,
      compliments: _selectedCompliments.toList(),
      tipCents: _tipCents,
    );
  }
}
