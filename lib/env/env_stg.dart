import 'package:envied/envied.dart';
import 'package:mobile/env/app_config.dart';

part 'env_stg.g.dart';

@Envied(path: '.env.stg', obfuscate: true)
final class EnvStg implements AppConfig {
  const EnvStg();

  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvStg._apiBaseUrl;

  @EnviedField(varName: 'MAPBOX_ACCESS_TOKEN')
  static final String _mapboxAccessToken = _EnvStg._mapboxAccessToken;

  @EnviedField(varName: 'FIREBASE_DATABASE_URL')
  static final String _firebaseDatabaseUrl = _EnvStg._firebaseDatabaseUrl;

  @override
  String get apiBaseUrl => _apiBaseUrl;

  @override
  String get mapboxAccessToken => _mapboxAccessToken;

  @override
  String get firebaseDatabaseUrl => _firebaseDatabaseUrl;
}
