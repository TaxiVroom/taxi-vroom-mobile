import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:mobile/core/widgets/place_list_tile.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_overview.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Mockup screen 3: waiting for a ride, with where the demand is.
class OnlinePanel extends StatelessWidget {
  const OnlinePanel({
    required this.demand,
    required this.receivesBookings,
    required this.isConnected,
    required this.isSwitching,
    required this.onGoOfflinePressed,
    required this.onReceivesBookingsChanged,
    this.failureMessage,
    super.key,
  });

  final DemandOverview demand;
  final bool receivesBookings;

  // Without connection, passengers no longer see the driver.
  final bool isConnected;
  final bool isSwitching;
  final VoidCallback onGoOfflinePressed;
  final ValueChanged<bool> onReceivesBookingsChanged;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    return BottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected) ...[
            _buildConnectionLost(),
            const SizedBox(height: 12),
          ],
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'En attente de course',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                'Lumineux vert',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _demandSummary,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          PlaceListTile(
            icon: Icons.event_outlined,
            title: 'Recevoir les réservations',
            subtitle: 'Courses programmées dans votre zone',
            trailing: Switch(
              value: receivesBookings,
              onChanged: onReceivesBookingsChanged,
            ),
          ),
          if (failureMessage case final message?) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 8),
          SecondaryButton(
            onPressed: isSwitching ? null : onGoOfflinePressed,
            alignment: Alignment.center,
            child: const Text('Passer hors ligne'),
          ),
        ],
      ),
    );
  }

  // Firebase writes the driver back by itself once reconnected.
  Widget _buildConnectionLost() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Connexion perdue. ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'Vous n’êtes plus visible des passagers. '
                        'Reconnexion automatique…',
                  ),
                ],
              ),
              style: TextStyle(fontSize: 13, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  // "Zone Centre, 3 taxis libres autour de vous. Demande forte à la gare,
  // à 6 min."
  String get _demandSummary {
    final taxis = demand.freeTaxiCount > 1
        ? '${demand.freeTaxiCount} taxis libres'
        : '${demand.freeTaxiCount} taxi libre';
    final summary = 'Zone ${demand.areaName}, $taxis autour de vous.';
    final highDemand = demand.closestHighDemand;
    final name = highDemand?.name;
    if (highDemand == null || name == null) return summary;
    return '$summary Demande forte : ${name.toLowerCase()}, '
        'à ${highDemand.driveMinutes} min.';
  }
}
