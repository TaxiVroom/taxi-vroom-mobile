import 'package:envied/envied.dart';
import 'package:mobile/env/app_config.dart';

part 'env_dev.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
final class EnvDev implements AppConfig {
  const EnvDev();

  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvDev._apiBaseUrl;

  @override
  String get apiBaseUrl => _apiBaseUrl;
}
