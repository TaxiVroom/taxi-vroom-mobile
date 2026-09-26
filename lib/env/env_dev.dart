import 'package:envied/envied.dart';
import 'package:mobile/env/app_config.dart';

part 'env_dev.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
final class EnvDev implements AppConfig {
  const EnvDev();

  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvDev._apiBaseUrl;

  @EnviedField(varName: 'MAPBOX_ACCESS_TOKEN')
  static final String _mapboxAccessToken = _EnvDev._mapboxAccessToken;

  @override
  String get apiBaseUrl => _apiBaseUrl;

  @override
  String get mapboxAccessToken => _mapboxAccessToken;
}
