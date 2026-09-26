import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Bottom panel of the home screen: one question, "Où allez-vous ?".
class WhereToPanel extends StatelessWidget {
  const WhereToPanel({
    required this.recentDestinations,
    required this.nearbyTaxiCount,
    super.key,
  });

  final List<RecentDestination> recentDestinations;
  final int nearbyTaxiCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x24000000), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWhereToButton(),
          const SizedBox(height: 12),
          _buildShortcuts(),
          const SizedBox(height: 8),
          for (final destination in recentDestinations)
            _buildRecentDestination(destination),
          const SizedBox(height: 8),
          _buildFreeTaxiCount(),
        ],
      ),
    );
  }

  // The destination screen (mockup screen 4) is not built yet: taps do nothing.
  Widget _buildWhereToButton() {
    return SecondaryButton(
      onPressed: () {},
      alignment: Alignment.centerLeft,
      leading: const Icon(Icons.search),
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 16),
          SizedBox(width: 4),
          Text('Maintenant'),
        ],
      ),
      child: const Text(
        'Où allez-vous ?',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildShortcuts() {
    return Row(
      children: [
        _buildShortcut(Icons.home_outlined, 'Maison'),
        const SizedBox(width: 8),
        _buildShortcut(Icons.work_outline, 'Travail'),
        const SizedBox(width: 8),
        _buildShortcut(Icons.train_outlined, 'Gare'),
      ],
    );
  }

  Widget _buildShortcut(IconData icon, String label) {
    return Expanded(
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
    );
  }

  Widget _buildRecentDestination(RecentDestination destination) {
    final distance = destination.distanceKm.toStringAsFixed(1).replaceAll('.', ',');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${destination.address}, $distance km',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTaxiCount() {
    final label = nearbyTaxiCount > 1
        ? '$nearbyTaxiCount taxis libres autour de vous'
        : '$nearbyTaxiCount taxi libre autour de vous';
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: AppColors.freeTaxi,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
      ],
    );
  }
}
