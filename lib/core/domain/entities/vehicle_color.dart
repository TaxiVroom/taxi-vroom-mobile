// The colors a driver picks for their taxi, the same list as the API.
// Spec taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md.
enum VehicleColor {
  black('BLACK', label: 'Noir', adjective: 'noire'),
  white('WHITE', label: 'Blanc', adjective: 'blanche'),
  grey('GREY', label: 'Gris', adjective: 'grise'),
  silver('SILVER', label: 'Argent', adjective: 'argent'),
  blue('BLUE', label: 'Bleu', adjective: 'bleue'),
  red('RED', label: 'Rouge', adjective: 'rouge'),
  green('GREEN', label: 'Vert', adjective: 'verte'),
  beige('BEIGE', label: 'Beige', adjective: 'beige'),
  brown('BROWN', label: 'Marron', adjective: 'marron'),
  other('OTHER', label: 'Autre');

  const VehicleColor(this.apiValue, {required this.label, this.adjective});

  final String apiValue;

  // In the driver's list: "Gris".
  final String label;

  // After the model, for the passenger: "Renault Austral grise". Null for
  // "Autre", which says nothing to look for.
  final String? adjective;

  static VehicleColor fromApi(String value) => VehicleColor.values.firstWhere(
    (color) => color.apiValue == value,
    orElse: () => VehicleColor.other,
  );
}
