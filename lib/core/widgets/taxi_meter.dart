import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The taxi's meter: the legal price, mirrored live in the apps of the
/// passenger and of the driver.
class TaxiMeter extends StatelessWidget {
  const TaxiMeter({
    required this.tariff,
    required this.amountCents,
    required this.caption,
    required this.detail,
    this.trailingDetail,
    super.key,
  });

  // Regulated tariff applied by the meter (A, B, C or D).
  final String tariff;

  final int amountCents;

  // Top right, e.g. "Compteur".
  final String caption;

  // Below the amount, e.g. "9,4 km restants" or the destination.
  final String detail;

  // Below the amount, on the right.
  final String? trailingDetail;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 12,
      color: AppColors.successBackground,
    );
    final trailingDetail = this.trailingDetail;
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
                  'Tarif $tariff',
                  style: textStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                caption,
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatEuro(amountCents),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.successBackground,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              if (trailingDetail != null)
                Text(trailingDetail, style: textStyle),
            ],
          ),
        ],
      ),
    );
  }
}
