// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import '../handler/handler.dart';
import 'middleware.dart';

extension Middleware$Handler on Iterable<Middleware> {
  /// Returns a [Handler] that wraps the [handler] with the [Middleware] stack.
  Handler<T> makeHandler<T>(Handler<T> handler) =>
      _MiddlewareHandler(handler, this);
}

class _MiddlewareHandler<T> implements Handler<T> {
  final Handler<T> handler;
  final Iterable<Middleware> middleware;

  const _MiddlewareHandler(this.handler, this.middleware);

  @override
  Future<T> handle(HttpRequest request) async {
    // Create a completer that will complete when the handler completes.
    final completer = Completer<T>.sync();

    // Create a next function that will process the next middleware.
    final next = middleware.reversed.fold(
      () async => completer.complete(await handler.handle(request)),
      (next, middleware) => () => middleware.process(request, next),
    );

    // Process the middleware stack and return the future.
    return next().then((_) => completer.future);
  }
}

extension<T> on Iterable<T> {
  /// Reverse the order of the elements in this iterable.
  Iterable<T> get reversed => toList(growable: false).reversed;
}
