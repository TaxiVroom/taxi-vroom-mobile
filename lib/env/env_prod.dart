import 'package:envied/envied.dart';
import 'package:mobile/env/app_config.dart';

part 'env_prod.g.dart';

@Envied(path: '.env.prod', obfuscate: true)
final class EnvProd implements AppConfig {
  const EnvProd();

  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvProd._apiBaseUrl;

  @EnviedField(varName: 'MAPBOX_ACCESS_TOKEN')
  static final String _mapboxAccessToken = _EnvProd._mapboxAccessToken;

  @override
  String get apiBaseUrl => _apiBaseUrl;

  @override
  String get mapboxAccessToken => _mapboxAccessToken;
}
