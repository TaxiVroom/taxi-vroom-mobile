import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The end of validity of a document, chosen in a calendar: only the days
/// after today. Built on shadcn_flutter's DatePicker (0.0.51,
/// lib/src/components/form/date_picker.dart). Spec
/// taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 2.
class ExpiryDateField extends StatelessWidget {
  const ExpiryDateField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Date d'expiration",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DatePicker(
          value: value,
          onChanged: onChanged,
          mode: PromptMode.dialog,
          dialogTitle: const Text("Date d'expiration"),
          placeholder: const Text('Choisir la date'),
          stateBuilder: (date) =>
              date.isAfter(today) ? DateState.enabled : DateState.disabled,
        ),
      ],
    );
  }
}
