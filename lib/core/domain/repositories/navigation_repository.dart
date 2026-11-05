import 'package:mobile/core/utils/result.dart';

abstract class NavigationRepository {
  // In another app, or the browser when that app is not installed.
  Future<Result<void>> open(Uri link);
}
