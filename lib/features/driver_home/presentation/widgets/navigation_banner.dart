import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/domain/entities/navigation_step.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The same banner while the position and the route come: the driver sees
/// the guidance is on its way, not an empty screen.
class NavigationLoadingBanner extends StatelessWidget {
  const NavigationLoadingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Calcul de l’itinéraire…',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Guidance at the top of the screen, readable at a glance while driving:
/// "Dans 200 m, à droite", the road, and the time left.
class NavigationBanner extends StatelessWidget {
  const NavigationBanner({required this.guidance, super.key});

  final Guidance guidance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 34, color: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _instruction,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (guidance.roadName.isNotEmpty)
                  Text(
                    guidance.roadName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${guidance.minutesLeft} min',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Closer than this, the driver is there.
  static const _arrivedMeters = 20;

  // "Dans 200 m, à droite".
  String get _instruction {
    final meters = guidance.metersToManeuver;
    final distance = formatDistanceMeters(meters);
    return switch (guidance.nextManeuver) {
      Maneuver.arrive when meters <= _arrivedMeters => 'Vous êtes arrivé',
      Maneuver.arrive => 'Arrivée dans $distance',
      Maneuver.depart => 'Démarrez',
      final maneuver => 'Dans $distance, ${_direction(maneuver)}',
    };
  }

  String _direction(Maneuver maneuver) => switch (maneuver) {
    Maneuver.slightRight => 'légèrement à droite',
    Maneuver.right => 'à droite',
    Maneuver.sharpRight => 'franchement à droite',
    Maneuver.slightLeft => 'légèrement à gauche',
    Maneuver.left => 'à gauche',
    Maneuver.sharpLeft => 'franchement à gauche',
    Maneuver.uturn => 'faites demi-tour',
    Maneuver.roundabout => 'au rond-point',
    Maneuver.straight || Maneuver.depart || Maneuver.arrive => 'tout droit',
  };

  IconData get _icon => switch (guidance.nextManeuver) {
    Maneuver.slightRight => Icons.turn_slight_right,
    Maneuver.right => Icons.turn_right,
    Maneuver.sharpRight => Icons.turn_sharp_right,
    Maneuver.slightLeft => Icons.turn_slight_left,
    Maneuver.left => Icons.turn_left,
    Maneuver.sharpLeft => Icons.turn_sharp_left,
    Maneuver.uturn => Icons.u_turn_left,
    Maneuver.roundabout => Icons.roundabout_right,
    Maneuver.arrive => Icons.flag,
    Maneuver.straight || Maneuver.depart => Icons.straight,
  };
}
