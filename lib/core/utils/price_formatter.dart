// (2700, 3300) -> "27–33 €".
String formatEuroRange(int minCents, int maxCents) =>
    '${(minCents / 100).round()}–${(maxCents / 100).round()} €';

// 2967 -> "29,67 €".
String formatEuro(int cents) =>
    '${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
