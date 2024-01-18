import 'dart:async';
import 'dart:io';

import '../application.dart';
import 'middleware.dart';

class MiddlewareStack extends Iterable<Middleware> {
  final Application _application;

  MiddlewareStack(Application application) : _application = application;

  /// Internal middleware stack.
  final _stack = <Middleware>[];

  @override
  Iterator<Middleware> get iterator => _stack.iterator;

  /// Adds a [Middleware] to the stack.
  ///
  /// If [prepend] is `true`, the [middleware] will be added to the beginning of
  /// the stack.
  void use(Middleware middleware, {bool prepend = false}) {
    if (prepend) {
      _application.logger.config('Prepending middleware: $middleware');

      return _stack.insert(0, middleware);
    }

    _application.logger.config('Appending middleware: $middleware');
    _stack.add(middleware);
  }

  /// Adds a closure style [Middleware] to the stack.
  void closure(
    FutureOr<void> Function(HttpRequest request, Next next) process, {
    bool prepend = false,
  }) {
    return use(_ClosureMifddleware(process), prepend: prepend);
  }
}

class _ClosureMifddleware implements Middleware {
  final FutureOr<void> Function(HttpRequest request, Next next) closure;

  const _ClosureMifddleware(this.closure);

  @override
  Future<void> process(HttpRequest request, Next next) async =>
      closure(request, next);
}
