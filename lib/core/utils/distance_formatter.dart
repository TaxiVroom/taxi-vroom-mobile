// 14.8 -> "14,8 km" (French decimal comma).
String formatDistanceKm(double distanceKm) =>
    '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';

// Driving guidance: 196 -> "200 m", 1240 -> "1,2 km".
String formatDistanceMeters(int meters) => meters < 1000
    ? '${(meters / 10).round() * 10} m'
    : formatDistanceKm(meters / 1000);
