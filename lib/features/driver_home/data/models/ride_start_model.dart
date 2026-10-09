import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';

// A refused start is the body of the server's 422, told apart by its code
// (see the API's libs/exceptions/exception.codes.ts).
class RideStartModel {
  const RideStartModel({this.refusalCode, this.attemptsLeft});

  factory RideStartModel.fromJson(Map<String, dynamic> json) => RideStartModel(
    refusalCode: json['code'] as String,
    attemptsLeft: json['attemptsLeft'] as int?,
  );

  static const accepted = RideStartModel();

  static const _wrongCode = 'RIDE.WRONG_BOARDING_CODE';
  static const _locked = 'RIDE.BOARDING_CODE_LOCKED';

  // Null when the ride started.
  final String? refusalCode;
  final int? attemptsLeft;

  RideStart toDomain() => switch (refusalCode) {
    null => const RideStartAccepted(),
    _wrongCode => RideStartWrongCode(attemptsLeft: attemptsLeft!),
    _locked => const RideStartLocked(),
    final code => throw FormatException('Unknown ride start refusal: $code'),
  };
}
