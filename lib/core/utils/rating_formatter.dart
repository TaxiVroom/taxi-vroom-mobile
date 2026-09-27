// 4.87 -> "4,9" (French decimal comma).
String formatRating(double rating) =>
    rating.toStringAsFixed(1).replaceAll('.', ',');
