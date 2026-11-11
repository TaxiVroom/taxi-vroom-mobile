// (2700, 3300) -> "27–33 €". Widened to whole euros, never narrowed: the
// price announced must hold the estimate.
String formatEuroRange(int minCents, int maxCents) =>
    '${minCents ~/ 100}–${(maxCents / 100).ceil()} €';

// 5000 -> "50 €", e.g. a mark on a chart's axis.
String formatWholeEuro(int cents) => '${cents ~/ 100} €';

// 2967 -> "29,67 €".
String formatEuro(int cents) =>
    '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';

// What the driver types: "29,67", "29.67" or "29" -> 2967; null if it is not
// an amount.
int? parseEuroCents(String input) {
  final match = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$').firstMatch(input.trim());
  if (match == null) return null;
  final euros = int.parse(match.group(1)!);
  final cents = int.parse((match.group(2) ?? '0').padRight(2, '0'));
  return euros * 100 + cents;
}
