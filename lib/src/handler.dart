import 'dart:async';

import 'package:ht/ht.dart' show HttpMethod, Response;

import 'event.dart';
import 'middleware.dart';

/// Handles a matched route request.
typedef Handler = FutureOr<Response> Function(Event event);

/// Route handlers keyed by HTTP method.
typedef RouteHandlers = Map<HttpMethod?, Handler>;

/// Handles an error raised while processing a request.
typedef ErrorHandler =
    FutureOr<Response> Function(
      Object error,
      StackTrace stackTrace,
      Event event,
    );

/// Defines a route handler with local middleware and error handling.
///
/// Local middleware wraps only the returned handler. Local [onError] catches
/// errors thrown by that local middleware chain or the wrapped handler.
Handler defineHandler(
  Handler handler, {
  Iterable<Middleware> middleware = const [],
  ErrorHandler? onError,
}) {
  final localMiddleware = List<Middleware>.unmodifiable(middleware);
  if (localMiddleware.isEmpty && onError == null) {
    return handler;
  }

  return (event) async {
    Future<Response> runLocalChain() async {
      Next next = () async => await handler(event);
      for (final current in localMiddleware.reversed) {
        final previous = next;
        next = () async => await current(event, previous);
      }

      return next();
    }

    if (onError == null) {
      return await runLocalChain();
    }

    try {
      return await runLocalChain();
    } catch (error, stackTrace) {
      return await onError(error, stackTrace, event);
    }
  };
}
