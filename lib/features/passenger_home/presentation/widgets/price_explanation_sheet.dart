import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/core/widgets/section_label.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_tariff.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "Comment est calculé le prix ?": how the estimate follows the meter, with
/// the regulated tariffs it used.
class PriceExplanationSheet extends StatelessWidget {
  const PriceExplanationSheet({required this.tariff, super.key});

  final TaxiTariff tariff;

  static const _mutedStyle = TextStyle(fontSize: 13, color: AppColors.muted);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Comment est calculé le prix ?',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comme le taximètre : la prise en charge, puis le prix au '
              'kilomètre, ou le prix à l’heure quand le taxi roule lentement '
              'ou attend. L’estimation inclut le trajet du taxi jusqu’à vous. '
              'Le prix final est celui du taximètre.',
            ),
            const SizedBox(height: 16),
            SectionLabel('Tarifs réglementés (${tariff.departmentCode})'),
            ..._buildRows(),
            const SizedBox(height: 12),
            Text(
              'Nuit de ${_clock(tariff.nightStartMinute)} à '
              '${_clock(tariff.nightEndMinute)}, et toute la journée les '
              'dimanches et jours fériés. La fourchette va du taxi qui repart '
              'avec un client (A, B) au taxi qui repart à vide (C, D). Hors '
              'suppléments (bagages, 5e passager) et péages. '
              'Source : ${tariff.decree}.',
              style: _mutedStyle,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => closeSheet(context),
              alignment: Alignment.center,
              child: const Text('Compris'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRows() => [
    _buildRow('Prise en charge', formatEuro(tariff.pickupCents)),
    _buildRow('Tarif A, de jour', '${formatEuro(tariff.kmCentsA)}/km'),
    _buildRow('Tarif B, de nuit', '${formatEuro(tariff.kmCentsB)}/km'),
    _buildRow('Tarif C, de jour', '${formatEuro(tariff.kmCentsC)}/km'),
    _buildRow('Tarif D, de nuit', '${formatEuro(tariff.kmCentsD)}/km'),
    _buildRow('Attente, marche lente', '${formatEuro(tariff.hourlyCents)}/h'),
    _buildRow('Course minimum', formatEuro(tariff.minimumFareCents)),
  ];

  Widget _buildRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // 1140 -> "19:00".
  static String _clock(int minuteOfDay) => formatClockTime(
    DateTime(2000, 1, 1, minuteOfDay ~/ 60, minuteOfDay % 60),
  );
}
