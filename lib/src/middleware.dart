import 'dart:async';

import 'package:ht/ht.dart' show HttpMethod, Response;

import 'event.dart';

/// Continues execution to the next middleware or route handler.
typedef Next = Future<Response> Function();

/// Intercepts a request before the final route handler runs.
typedef Middleware = FutureOr<Response> Function(Event event, Next next);

/// Binds middleware to a route path and optional method.
final class MiddlewareRoute {
  /// Creates a middleware route binding.
  const MiddlewareRoute({
    required this.path,
    required this.handler,
    this.method,
  });

  /// Path pattern matched by the middleware.
  final String path;

  /// Optional HTTP method restriction.
  final HttpMethod? method;

  /// Middleware implementation.
  final Middleware handler;
}
