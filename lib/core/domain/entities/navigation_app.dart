import 'package:mobile/core/domain/entities/coordinates.dart';

// The navigation apps a driver can leave for, with the trip already filled
// in. Their links need no API key, and open the website without the app.
// Spec navigation-externe.md.
enum NavigationApp {
  googleMaps('Google Maps'),
  waze('Waze');

  const NavigationApp(this.label);

  // What the driver reads.
  final String label;

  // From the phone's position to [target], navigation started at once.
  // Docs: https://developers.google.com/maps/documentation/urls/get-started
  // and https://developers.google.com/waze/deeplinks
  Uri directionsTo(Coordinates target) {
    final point = '${target.latitude},${target.longitude}';
    return switch (this) {
      NavigationApp.googleMaps => Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': point,
        'travelmode': 'driving',
        'dir_action': 'navigate',
      }),
      NavigationApp.waze => Uri.https('waze.com', '/ul', {
        'll': point,
        'navigate': 'yes',
      }),
    };
  }
}
