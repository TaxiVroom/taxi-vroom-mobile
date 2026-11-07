// The driver and the taxi of RideRemoteDataSourceFake, which plays a ride
// without the backend. The real source reads both from rides/<id>/driver.
const Map<String, Map<String, Object>> simulatedDriverAndVehicleJson = {
  'driver': {
    'name': 'Luc S.',
    'rating': 4.9,
    'completedRides': 2340,
  },
  'vehicle': {
    'model': 'Toyota Corolla Touring',
    'color': 'BLACK',
    'plate': 'GH-482-KZ',
    'adsNumber': '118',
    'communeName': 'Strasbourg',
  },
};
