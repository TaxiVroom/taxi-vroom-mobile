import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Intercepteur Dio qui injecte automatiquement le token Firebase
/// dans chaque requête et le rafraîchit en cas de 401.
///
/// Placé dans le core car il sera partagé par tous les datasources
/// qui ont besoin d'appels authentifiés (passenger, driver, etc.).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required FirebaseAuth firebaseAuth,
    required Dio dio,
  }) : _firebaseAuth = firebaseAuth,
       _dio = dio;

  final FirebaseAuth _firebaseAuth;

  // Référence au Dio principal pour relancer la requête après refresh.
  final Dio _dio;

  // Header sentinelle pour éviter une boucle infinie si le refresh échoue aussi en 401.
  static const _retryHeader = 'X-Token-Refreshed';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Pas de forceRefresh ici : Firebase retourne le token en cache
      // s'il est encore valide, évitant un appel réseau inutile à chaque requête.
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.headers[_retryHeader] == true;

    if (is401 && !alreadyRetried) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        try {
          // Force le refresh : le token local est expiré ou révoqué côté serveur.
          final token = await user.getIdToken(true);

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $token';
          // Sentinelle : si ce retry renvoie encore 401, on ne boucle pas.
          options.headers[_retryHeader] = true;

          final response = await _dio.fetch<dynamic>(options);
          return handler.resolve(response);
        } catch (_) {
          // Refresh impossible (session révoquée, déconnexion Firebase, etc.)
          // On propage l'erreur — l'appelant décidera de déconnecter l'utilisateur.
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }
}
