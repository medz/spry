import 'package:ht/ht.dart' show HttpMethod;
import 'package:roux/roux.dart';

import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';

/// Creates a route router from generated route handlers.
Router<Handler> createHandlerRouter(Map<String, RouteHandlers> routes) {
  final router = Router<Handler>();
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
    return router.match(path, method: HttpMethod.head.value) ??
        router.match(path, method: HttpMethod.get.value);
  }

  return router.match(path, method: method);
}

/// Creates a middleware router that preserves duplicate matches.
Router<Middleware> createMiddlewareRouter(Iterable<MiddlewareRoute> routes) {
  final router = Router<Middleware>(duplicatePolicy: DuplicatePolicy.append);
  for (final MiddlewareRoute(:path, :handler, :method) in routes) {
    router.add(path, handler, method: method?.value);
  }

  return router;
}

/// Creates an error router that preserves duplicate matches.
Router<ErrorHandler> createErrorRouter(Iterable<ErrorRoute> routes) {
  final router = Router<ErrorHandler>(duplicatePolicy: DuplicatePolicy.append);
  for (final ErrorRoute(:method, :path, :handler) in routes) {
    router.add(path, handler, method: method?.value);
  }

  return router;
}
