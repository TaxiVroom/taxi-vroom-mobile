import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/distance_formatter.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The taxi's meter, mirrored live on the passenger's phone.
class TaxiMeter extends StatelessWidget {
  const TaxiMeter({required this.ride, super.key});

  final RideInProgress ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.freeTaxi, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Tarif ${ride.tariff}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successBackground,
                  ),
                ),
              ),
              const Text(
                'Compteur',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatEuro(ride.meterCents),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.successBackground,
            ),
          ),
          Text(
            '${formatDistanceKm(ride.remainingKm)} restants',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.successBackground,
            ),
          ),
        ],
      ),
    );
  }
}
