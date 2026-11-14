import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/core/data/datasources/shared_position_stream.dart';

Position _position(double latitude) => Position(
  longitude: 7.7,
  latitude: latitude,
  timestamp: DateTime(2026, 11, 14),
  accuracy: 1,
  altitude: 0,
  altitudeAccuracy: 1,
  heading: 0,
  headingAccuracy: 1,
  speed: 0,
  speedAccuracy: 1,
);

// The phone's position stream: each call to [open] is one stream of the
// plugin, which the test feeds and watches.
class _FakePlatform {
  final opened = <_OpenedStream>[];

  Stream<Position> open({required bool inBackground}) {
    final stream = _OpenedStream(inBackground: inBackground);
    opened.add(stream);
    return stream.controller.stream;
  }
}

class _OpenedStream {
  _OpenedStream({required this.inBackground}) {
    controller = StreamController<Position>(onCancel: () => isCancelled = true);
  }

  final bool inBackground;
  late final StreamController<Position> controller;
  bool isCancelled = false;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('SharedPositionStream', () {
    late _FakePlatform platform;
    late SharedPositionStream shared;

    setUp(() {
      platform = _FakePlatform();
      shared = SharedPositionStream(platform.open);
    });

    test('two listeners share one stream of the phone', () async {
      // Arrange
      final first = <double>[];
      final second = <double>[];
      shared.watch(inBackground: false).listen((p) => first.add(p.latitude));
      shared.watch(inBackground: false).listen((p) => second.add(p.latitude));

      // Act
      platform.opened.single.controller.add(_position(48.5));
      await _settle();

      // Assert
      expect(platform.opened, hasLength(1));
      expect(first, [48.5]);
      expect(second, [48.5]);
    });

    test(
      'a listener that needs the background arrives while a normal stream '
      'runs: the stream is reopened in the background, the first listener '
      'keeps its positions',
      () async {
        // Arrange: a screen listens first, without the background.
        final screen = <double>[];
        shared.watch(inBackground: false).listen((p) => screen.add(p.latitude));
        final normal = platform.opened.single;

        // Act: the driver goes online.
        shared.watch(inBackground: true).listen((_) {});
        platform.opened.last.controller.add(_position(48.6));
        await _settle();

        // Assert
        expect(platform.opened, hasLength(2));
        expect(normal.inBackground, isFalse);
        expect(normal.isCancelled, isTrue);
        expect(platform.opened.last.inBackground, isTrue);
        expect(screen, [48.6]);
      },
    );

    test(
      'a normal listener joining a background stream does not reopen it',
      () {
        // Arrange
        shared.watch(inBackground: true).listen((_) {});

        // Act
        shared.watch(inBackground: false).listen((_) {});

        // Assert
        expect(platform.opened, hasLength(1));
        expect(platform.opened.single.inBackground, isTrue);
      },
    );

    test(
      'the last background listener leaves: the stream goes back to normal '
      'for the listeners left',
      () async {
        // Arrange
        shared.watch(inBackground: false).listen((_) {});
        final background = shared.watch(inBackground: true).listen((_) {});
        final inBackground = platform.opened.last;

        // Act: the driver goes offline.
        await background.cancel();

        // Assert
        expect(platform.opened, hasLength(3));
        expect(inBackground.isCancelled, isTrue);
        expect(platform.opened.last.inBackground, isFalse);
      },
    );

    test(
      'the last listener leaves: the stream of the phone is stopped',
      () async {
        // Arrange
        final subscription = shared.watch(inBackground: false).listen((_) {});

        // Act
        await subscription.cancel();

        // Assert
        expect(platform.opened.single.isCancelled, isTrue);
      },
    );

    test(
      'a listener arriving after everyone left opens a new stream',
      () async {
        // Arrange
        final subscription = shared.watch(inBackground: false).listen((_) {});
        await subscription.cancel();

        // Act
        shared.watch(inBackground: true).listen((_) {});

        // Assert
        expect(platform.opened, hasLength(2));
        expect(platform.opened.last.inBackground, isTrue);
      },
    );

    test('an error of the phone reaches every listener', () async {
      // Arrange
      final errors = <Object>[];
      shared.watch(inBackground: false).listen((_) {}, onError: errors.add);
      shared.watch(inBackground: false).listen((_) {}, onError: errors.add);

      // Act
      platform.opened.single.controller.addError(StateError('no permission'));
      await _settle();

      // Assert
      expect(errors, hasLength(2));
    });

    test(
      'the stream of the phone ends: every listener ends, and the next one '
      'opens a new stream',
      () async {
        // Arrange
        var endedListeners = 0;
        shared
            .watch(inBackground: false)
            .listen((_) {}, onDone: () => endedListeners++);
        shared
            .watch(inBackground: false)
            .listen((_) {}, onDone: () => endedListeners++);

        // Act
        await platform.opened.single.controller.close();
        await _settle();
        shared.watch(inBackground: false).listen((_) {});

        // Assert
        expect(endedListeners, 2);
        expect(platform.opened, hasLength(2));
      },
    );
  });
}
