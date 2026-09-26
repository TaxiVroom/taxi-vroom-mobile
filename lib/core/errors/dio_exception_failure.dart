import 'package:dio/dio.dart';
import 'package:mobile/core/errors/failures.dart';

extension DioExceptionFailure on DioException {
  // No response means the server was never reached: a network problem.
  Failure toFailure() => response == null
      ? const NetworkFailure('Connexion impossible')
      : ServerFailure('Erreur serveur (${response!.statusCode})');
}
