import 'package:mobile/core/domain/entities/vehicle.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/rating_formatter.dart';
import 'package:mobile/features/passenger_home/domain/entities/driver.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The driver's initials, name, rating and taxi licence, with optional round
/// buttons at the end of the row.
class DriverSummary extends StatelessWidget {
  const DriverSummary({
    required this.driver,
    this.vehicle,
    this.actions = const [],
    super.key,
  });

  final Driver driver;

  // Null for a driver registered before the "Votre taxi" step existed: no
  // licence line.
  final Vehicle? vehicle;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final rating = driver.rating;
    final reputation = rating == null ? 'Nouveau' : '★ ${formatRating(rating)}';
    final vehicle = this.vehicle;
    return Row(
      children: [
        Avatar(initials: Avatar.getInitials(driver.name)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '$reputation, ${driver.completedRides} courses',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              if (vehicle != null)
                Text(
                  vehicle.licence,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
            ],
          ),
        ),
        for (final action in actions) ...[const SizedBox(width: 8), action],
      ],
    );
  }
}
