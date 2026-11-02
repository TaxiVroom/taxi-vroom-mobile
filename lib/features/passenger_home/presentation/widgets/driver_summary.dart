import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/rating_formatter.dart';
import 'package:mobile/features/passenger_home/domain/entities/driver.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The driver's initials, name, rating and taxi licence.
class DriverSummary extends StatelessWidget {
  const DriverSummary({required this.driver, super.key});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final rating = driver.rating;
    final reputation = rating == null ? 'Nouveau' : '★ ${formatRating(rating)}';
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
              Text(
                'Taxi n° ${driver.taxiNumber}, ${driver.city}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
