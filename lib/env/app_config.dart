abstract interface class AppConfig {
  String get apiBaseUrl;

  // Public Mapbox token (pk.…), safe to ship in the app.
  String get mapboxAccessToken;
}
