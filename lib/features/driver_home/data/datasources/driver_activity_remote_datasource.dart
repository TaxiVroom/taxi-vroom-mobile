import 'package:mobile/features/driver_home/data/models/driver_activity_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class DriverActivityRemoteDataSource {
  Future<DriverActivityModel> getActivity();

  Future<void> setOnline({required bool isOnline});
}
