import 'package:ht/ht.dart' show HttpMethod;
import 'package:roux/roux.dart';

import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';

/// Creates a route router from generated route handlers.
Router<Handler> createHandlerRouter(
  Map<String, RouteHandlers> routes, {
  bool caseSensitive = true,
  int? cacheCapacity,
}) {
  final router = Router<Handler>(
    caseSensitive: caseSensitive,
    cache: cacheCapacity == null ? null : LRUCache<Handler>(cacheCapacity),
  );
  for (final MapEntry(key: path, value: handlers) in routes.entries) {
    for (final MapEntry(key: method, value: handler) in handlers.entries) {
      router.add(path, handler, method: method?.value);
    }
  }

  return router;
}

/// Matches the best route handler for [path] and [method].
RouteMatch<Handler>? matchHandler(
  Router<Handler> router,
  String path,
  String method,
) {
  if (method == HttpMethod.head.value) {
    return router.find(path, method: HttpMethod.head.value) ??
        router.find(path, method: HttpMethod.get.value);
  }

  return router.find(path, method: method);
}

/// Creates a middleware router for broad-to-specific scope collection.
Router<Middleware> createMiddlewareRouter(
  Iterable<MiddlewareRoute> routes, {
  bool caseSensitive = true,
}) {
  final router = Router<Middleware>(caseSensitive: caseSensitive);
  for (final MiddlewareRoute(:path, :handler, :method) in routes) {
    router.add(path, handler, method: method?.value);
  }

  return router;
}

/// Creates an error router for broad-to-specific scope collection.
Router<ErrorHandler> createErrorRouter(
  Iterable<ErrorRoute> routes, {
  bool caseSensitive = true,
}) {
  final router = Router<ErrorHandler>(caseSensitive: caseSensitive);
  for (final ErrorRoute(:method, :path, :handler) in routes) {
    router.add(path, handler, method: method?.value);
  }

  return router;
}
