import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/connection_lost_banner.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Bottom panel of the home screen: one question, "Où allez-vous ?".
class WhereToPanel extends StatelessWidget {
  const WhereToPanel({
    required this.nearbyTaxiCount,
    required this.isConnected,
    required this.onWhereToPressed,
    required this.onShortcutPressed,
    super.key,
  });

  final int nearbyTaxiCount;

  // Without connection, the taxis shown may no longer be where they are.
  final bool isConnected;
  final VoidCallback onWhereToPressed;

  // "Maison" or "Travail".
  final ValueChanged<SavedPlaceKind> onShortcutPressed;

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
          // Only "Maison" and "Travail": the recent destinations are in
          // "Votre trajet" (user's decision, spec destinations-recentes.md).
          const SizedBox(height: 16),
          _buildFreeTaxiCount(),
        ],
      ),
    );
  }

  // The pickup time is chosen on the taxi choice only (spec
  // heure-de-prise-en-charge.md).
  Widget _buildWhereToButton() {
    return SecondaryButton(
      onPressed: onWhereToPressed,
      alignment: Alignment.centerLeft,
      leading: const Icon(Icons.search),
      child: const Text(
        'Où allez-vous ?',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildShortcuts() {
    return Row(
      children: [
        _buildShortcut(Icons.home_outlined, SavedPlaceKind.home),
        const SizedBox(width: 8),
        _buildShortcut(Icons.work_outline, SavedPlaceKind.work),
      ],
    );
  }

  Widget _buildShortcut(IconData icon, SavedPlaceKind kind) {
    return Expanded(
      child: OutlineButton(
        onPressed: () => onShortcutPressed(kind),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(kind.label, maxLines: 1),
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
