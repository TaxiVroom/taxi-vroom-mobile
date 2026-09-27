abstract interface class AppConfig {
  String get apiBaseUrl;

  // Public Mapbox token (pk.…), safe to ship in the app.
  String get mapboxAccessToken;

  // Firebase Realtime Database outside the US: the app must be given its URL.
  String get firebaseDatabaseUrl;
}
