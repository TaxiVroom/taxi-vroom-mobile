import 'package:mobile/core/utils/result.dart';

abstract class EnterpriseContactRepository {
  // The number "Nous contacter" calls, in E.164.
  Future<Result<String>> getPhone();
}
