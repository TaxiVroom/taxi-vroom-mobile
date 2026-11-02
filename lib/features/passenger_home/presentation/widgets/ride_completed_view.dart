import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/choice_button.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_compliment.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 9: total and meter breakdown, then rating the driver. No
/// tip in the app: nothing is paid through it.
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
    required List<RideCompliment> compliments,
  })
  onFinished;

  @override
  State<RideCompletedView> createState() => _RideCompletedViewState();
}

class _RideCompletedViewState extends State<RideCompletedView> {
  // 0 star means the passenger did not rate the ride.
  int _stars = 0;
  final Set<RideCompliment> _selectedCompliments = {};

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
            // Paid on board: every taxi must take cards (Code des transports,
            // art. L3121-11-2).
            const Text(
              'À régler au chauffeur, par carte ou en espèces',
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
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: widget.isSubmitting ? null : _onFinished,
              alignment: Alignment.center,
              trailing: widget.isSubmitting
                  ? const AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(onSurface: true),
                    )
                  : null,
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
          _buildFareRow('Total', ride.totalCents, isTotal: true),
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
        for (final compliment in RideCompliment.values)
          ChoiceButton(
            label: compliment.label,
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

  void _onFinished() {
    widget.onFinished(
      stars: _stars,
      compliments: _selectedCompliments.toList(),
    );
  }
}
