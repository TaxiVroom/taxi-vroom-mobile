import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Pickup, then destination, linked by a line like on a map: a dot for the
/// start, a square for the end.
class TripStops extends StatelessWidget {
  const TripStops({
    required this.pickupName,
    required this.destinationName,
    this.pickupDetail,
    this.destinationDetail,
    super.key,
  });

  final String pickupName;
  final String destinationName;

  // E.g. "Prise en charge à 1,2 km, 4 min".
  final String? pickupDetail;

  // E.g. "Environ 22 min de trajet".
  final String? destinationDetail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                // Longer when the stops have a detail line.
                height: pickupDetail == null ? 22 : 34,
                color: AppColors.muted,
              ),
              Container(width: 10, height: 10, color: AppColors.ink),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStop(pickupName, pickupDetail),
              const SizedBox(height: 8),
              _buildStop(destinationName, destinationDetail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStop(String name, String? detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (detail != null)
          Text(
            detail,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
      ],
    );
  }
}
