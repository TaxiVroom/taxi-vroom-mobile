import 'package:envied/envied.dart';
import 'package:mobile/env/app_config.dart';

part 'env_stg.g.dart';

@Envied(path: '.env.stg', obfuscate: true)
final class EnvStg implements AppConfig {
  const EnvStg();

  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvStg._apiBaseUrl;

  @override
  String get apiBaseUrl => _apiBaseUrl;
}
