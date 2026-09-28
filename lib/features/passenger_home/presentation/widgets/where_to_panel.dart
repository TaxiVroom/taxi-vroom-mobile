import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/connection_lost_banner.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/pickup_time_chip.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Bottom panel of the home screen: one question, "Où allez-vous ?".
class WhereToPanel extends StatelessWidget {
  const WhereToPanel({
    required this.recentDestinations,
    required this.nearbyTaxiCount,
    required this.isConnected,
    required this.onWhereToPressed,
    super.key,
  });

  final List<RecentDestination> recentDestinations;
  final int nearbyTaxiCount;

  // Without connection, the taxis shown may no longer be where they are.
  final bool isConnected;
  final VoidCallback onWhereToPressed;

  @override
  Widget build(BuildContext context) {
    return BottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected) ...[
            const ConnectionLostBanner(
              consequence: 'Les taxis affichés ne sont peut-être plus à jour.',
            ),
            const SizedBox(height: 12),
          ],
          _buildWhereToButton(),
          const SizedBox(height: 12),
          _buildShortcuts(),
          const SizedBox(height: 8),
          for (final destination in recentDestinations)
            PlaceListTile(
              icon: Icons.history,
              title: destination.name,
              subtitle:
                  '${destination.address}, '
                  '${formatDistanceKm(destination.distanceKm)}',
            ),
          const SizedBox(height: 8),
          _buildFreeTaxiCount(),
        ],
      ),
    );
  }

  Widget _buildWhereToButton() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            onPressed: onWhereToPressed,
            alignment: Alignment.centerLeft,
            leading: const Icon(Icons.search),
            child: const Text(
              'Où allez-vous ?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const PickupTimeChip(),
      ],
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

  Widget _buildFreeTaxiCount() {
    final label = switch (nearbyTaxiCount) {
      0 => 'Aucun taxi libre autour de vous',
      1 => '1 taxi libre autour de vous',
      _ => '$nearbyTaxiCount taxis libres autour de vous',
    };
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
