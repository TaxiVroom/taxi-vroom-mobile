import 'dart:async';

import 'package:geolocator/geolocator.dart';

// One position stream of the phone for the whole app, in the background mode
// that its listeners need.
//
// geolocator_android 5.1.0 hands every caller the first stream created and
// ignores the settings of the next ones: a screen listening before the driver
// went online kept the foreground service from starting, and Android cut the
// app's network when it left the screen. So the stream is reopened whenever
// the need for the background changes.
class SharedPositionStream {
  SharedPositionStream(this._open);

  final Stream<Position> Function({required bool inBackground}) _open;
  final _listeners = <_Listener>[];
  StreamSubscription<Position>? _subscription;
  bool _isOpenInBackground = false;

  Stream<Position> watch({required bool inBackground}) {
    return Stream<Position>.multi((controller) {
      final listener = _Listener(controller, inBackground: inBackground);
      _listeners.add(listener);
      _update();
      controller.onCancel = () {
        _listeners.remove(listener);
        _update();
      };
    }, isBroadcast: true);
  }

  void _update() {
    if (_listeners.isEmpty) {
      _close();
      return;
    }
    final needsBackground = _listeners.any((listener) => listener.inBackground);
    if (_subscription != null && _isOpenInBackground == needsBackground) return;

    _close();
    _isOpenInBackground = needsBackground;
    _subscription = _open(inBackground: needsBackground).listen(
      (position) {
        for (final listener in List.of(_listeners)) {
          listener.controller.add(position);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        for (final listener in List.of(_listeners)) {
          listener.controller.addError(error, stackTrace);
        }
      },
      onDone: _end,
    );
  }

  // The stream of the phone ended (a refused permission, for example): every
  // listener ends with it, and the next one opens a new stream.
  void _end() {
    _subscription = null;
    final listeners = List.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      unawaited(listener.controller.close());
    }
  }

  void _close() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}

class _Listener {
  _Listener(this.controller, {required this.inBackground});

  final MultiStreamController<Position> controller;
  final bool inBackground;
}
