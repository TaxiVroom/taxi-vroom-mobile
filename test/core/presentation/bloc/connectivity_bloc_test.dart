import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/repositories/connection_repository.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/presentation/bloc/connectivity_bloc.dart';

// The device's connection, which the test loses and gets back.
class _FakeConnection implements ConnectionRepository {
  final controller = StreamController<bool>();

  @override
  Stream<bool> watchConnection() => controller.stream;
}

void main() {
  group('ConnectivityBloc', () {
    late _FakeConnection connection;

    setUp(() => connection = _FakeConnection());
    // Not awaited: closing a stream nobody listened to never completes.
    tearDown(() => unawaited(connection.controller.close()));

    ConnectivityBloc build() => ConnectivityBloc(
      watchConnectionUseCase: WatchConnectionUseCase(connection),
    );

    test('starts connected, before anything is known', () {
      // Arrange + Act
      final bloc = build();

      // Assert
      expect(bloc.state.isConnected, isTrue);
    });

    blocTest<ConnectivityBloc, ConnectivityState>(
      'follows the connection when it is lost and when it comes back',
      build: build,
      act: (bloc) async {
        // Arrange: the bloc watches the connection.
        bloc.add(const ConnectivityWatchStarted());
        await Future<void>.delayed(Duration.zero);

        // Act: lost, then back.
        connection.controller
          ..add(false)
          ..add(true);
        await Future<void>.delayed(Duration.zero);
      },
      // Assert
      expect: () => const [
        ConnectivityState(isConnected: false),
        ConnectivityState(),
      ],
    );
  });
}
