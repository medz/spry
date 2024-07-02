import 'dart:async';

import 'event.dart';
import 'handler.dart';

Handler defineHandler(FutureOr<void> Function(Event event) handle) {
  return _ClosureHandler(handle);
}

final class _ClosureHandler implements Handler {
  const _ClosureHandler(this._closure);

  final FutureOr<void> Function(Event event) _closure;

  @override
  Future<void> handle(Event event) async {
    return _closure(event);
  }
}
