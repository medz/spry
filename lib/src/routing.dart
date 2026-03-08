import 'package:roux/roux.dart';

import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';

Router<Handler> createHandlerRouter(Map<String, RouteHandlers> routes) {
  final router = Router<Handler>();
  for (final MapEntry(key: path, value: handlers) in routes.entries) {
    for (final MapEntry(key: method, value: handler) in handlers.entries) {
      router.add(path, handler, method: method);
    }
  }

  return router;
}

RouteMatch<Handler>? matchHandler(
  Router<Handler> router,
  String path,
  String method,
) {
  if (method == 'HEAD') {
    return router.match(path, method: 'HEAD') ??
        router.match(path, method: 'GET');
  }

  return router.match(path, method: method);
}

Router<Middleware> createMiddlewareRouter(Iterable<MiddlewareRoute> routes) {
  final router = Router<Middleware>();
  for (final MiddlewareRoute(:path, :handler, :method) in routes) {
    router.add(path, handler, method: method);
  }

  return router;
}

Router<ErrorHandler> createErrorRouter(Iterable<ErrorRoute> routes) {
  final router = Router<ErrorHandler>();
  for (final ErrorRoute(:method, :path, :handler) in routes) {
    router.add(path, handler, method: method);
  }

  return router;
}
