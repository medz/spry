import 'dart:async';
import 'dart:io';

import 'handler.dart';

class ClosureHandler<T> implements Handler<T> {
  final FutureOr<T> Function(HttpRequest) _closure;

  const ClosureHandler(FutureOr<T> Function(HttpRequest request) closure)
      : _closure = closure;

  @override
  FutureOr<T> handle(HttpRequest request) => _closure(request);
}

extension FutureOrClosure$MakeHandler<T> on FutureOr<T> Function(HttpRequest) {
  /// Returns a [Handler] that wraps the this.
  Handler<T> makeHandler() => ClosureHandler<T>(this);
}
