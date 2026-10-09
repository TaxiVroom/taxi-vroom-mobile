// What the backend does not know yet: the vehicles and the drivers' ratings.
// Merged into the ride's JSON by the real and the fake ride sources alike.
const Map<String, Map<String, Object>> simulatedDriverAndVehicleJson = {
  'driver': {
    'name': 'Luc S.',
    'rating': 4.9,
    'completedRides': 2340,
    'taxiNumber': '118',
    'city': 'Strasbourg',
  },
  'vehicle': {
    'model': 'Toyota Corolla Touring',
    'color': 'noire',
    'plate': 'GH-482-KZ',
    'department': '67',
  },
};
