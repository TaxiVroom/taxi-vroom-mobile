import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

// The API, which always answers 200.
class _OkServer implements HttpClientAdapter {
  int received = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    received++;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthInterceptor', () {
    late _MockUser user;
    late _OkServer server;
    late Dio dio;

    setUp(() {
      user = _MockUser();
      server = _OkServer();
      final auth = _MockFirebaseAuth();
      when(() => auth.currentUser).thenReturn(user);
      dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
        ..httpClientAdapter = server;
      dio.interceptors.add(AuthInterceptor(firebaseAuth: auth, dio: dio));
    });

    test('puts the token in the request', () async {
      // Arrange
      when(() => user.getIdToken()).thenAnswer((_) async => 'token-1');

      // Act
      final response = await dio.get<dynamic>('/v1/me');

      // Assert
      expect(
        response.requestOptions.headers['Authorization'],
        'Bearer token-1',
      );
    });

    test(
      'no token because the phone is offline: the request fails at once '
      'as a connection error, it does not hang',
      () async {
        // Arrange: Firebase cannot reach its servers to renew the token.
        when(
          () => user.getIdToken(),
        ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

        // Act
        final request = dio.get<dynamic>('/v1/me');

        // Assert
        await expectLater(
          request,
          throwsA(
            isA<DioException>().having(
              (error) => error.type,
              'type',
              DioExceptionType.connectionError,
            ),
          ),
        );
        expect(server.received, 0);
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });
}
