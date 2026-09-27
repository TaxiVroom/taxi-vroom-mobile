// 14.8 -> "14,8 km" (French decimal comma).
String formatDistanceKm(double distanceKm) =>
    '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';
