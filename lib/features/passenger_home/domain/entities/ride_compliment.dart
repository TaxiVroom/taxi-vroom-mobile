// What the passenger can praise when rating a driver.
enum RideCompliment {
  smoothDriving('SMOOTH_DRIVING', 'Conduite douce'),
  punctual('PUNCTUAL', 'Ponctuel'),
  luggageHelp('LUGGAGE_HELP', 'Aide bagages');

  const RideCompliment(this.code, this.label);

  // As the backend knows it.
  final String code;
  final String label;
}
