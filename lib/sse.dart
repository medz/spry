import 'dart:async';
import 'dart:typed_data';

import 'spry.dart';

abstract interface class SSE implements Event {
  /// Send a
}

extension RoutesSSE on Routes {
  void sse<T>(String path, FutureOr<T> Function(SSE sse) handler) {
    
    // return get<T>(
    //   path,
    //   (event) => hijack<T>(
    //     event,
    //     (stream, sink) => handler(_SseImpl(event, stream, sink)),
    //   ),
    // );
  }

  static _createHijackSseHandler<T>(
      SSE sse, FutureOr<T> Function(SSE sse) handler) {}
}

final class _SseImpl implements SSE {
  const _SseImpl(this.event, this.stream, this.sink);

  final Event event;
  final Stream<Uint8List> stream;
  final Sink<Uint8List> sink;

  @override
  T? get<T>(Object? key) => event.get<T>(key);

  @override
  void remove(Object? key) => event.remove(key);

  @override
  void set<T>(Object? key, T value) => event.set<T>(key, value);
}
