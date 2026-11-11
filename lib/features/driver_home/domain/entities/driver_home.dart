import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// Everything the driver home screen shows, offline and online. Its figures
// load apart: DriverActivity.
class DriverHome extends Equatable {
  const DriverHome({required this.position, this.isOnline = false});

  final Coordinates position;

  // Online: the taxi light is green and ride requests can come in. The app
  // always starts offline: only this phone knows it, not the API.
  final bool isOnline;

  DriverHome withOnline({required bool isOnline}) =>
      DriverHome(position: position, isOnline: isOnline);

  @override
  List<Object?> get props => [position, isOnline];
}
