import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:mobile/core/widgets/bottom_panel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Asks the amount shown on the taximeter, when it differs from the one read
/// by the app. Null when the sheet is closed without confirming.
Future<int?> openMeterAmountSheet(
  BuildContext context, {
  required int currentCents,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MeterAmountSheet(currentCents: currentCents),
  );
}

class MeterAmountSheet extends StatefulWidget {
  const MeterAmountSheet({required this.currentCents, super.key});

  final int currentCents;

  @override
  State<MeterAmountSheet> createState() => _MeterAmountSheetState();
}

class _MeterAmountSheetState extends State<MeterAmountSheet> {
  // "29,67", without the euro sign.
  late final _controller = TextEditingController(
    text: formatEuro(widget.currentCents).replaceAll(' €', ''),
  );
  bool _isInvalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Stays above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: BottomPanel(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Montant affiché sur le taximètre',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                features: const [InputFeature.trailing(Text('€'))],
              ),
              if (_isInvalid) ...[
                const SizedBox(height: 8),
                const Text(
                  'Entrez un montant, par exemple 29,67.',
                  style: TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: _onConfirmed,
                alignment: Alignment.center,
                child: const Text('Valider le montant'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirmed() {
    final cents = parseEuroCents(_controller.text);
    if (cents == null) {
      setState(() => _isInvalid = true);
      return;
    }
    Navigator.of(context).pop(cents);
  }
}
