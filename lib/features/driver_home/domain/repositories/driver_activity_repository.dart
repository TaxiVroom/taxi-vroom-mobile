import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';

abstract class DriverActivityRepository {
  Future<Result<DriverActivity>> getActivity();

  Future<Result<void>> setOnline({required bool isOnline});
}
