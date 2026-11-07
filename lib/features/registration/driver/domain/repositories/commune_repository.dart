import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/driver/domain/entities/commune.dart';

abstract class CommuneRepository {
  // The communes whose name starts like [name], the biggest first.
  Future<Result<List<Commune>>> searchCommunes(String name);
}
