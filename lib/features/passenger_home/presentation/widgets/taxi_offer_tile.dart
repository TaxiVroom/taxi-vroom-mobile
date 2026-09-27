import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// One selectable kind of taxi with its estimated price range.
class TaxiOfferTile extends StatelessWidget {
  const TaxiOfferTile({
    required this.offer,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  final TaxiOffer offer;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${offer.description}, à ${offer.pickupEtaMinutes} min',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatEuroRange(offer.minPriceCents, offer.maxPriceCents),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  offer.priceNote ?? 'estimé',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
