import 'package:routingkit/routingkit.dart';

import '../app/types.dart';
import 'http_method.dart';

typedef HandlerRouter = RouterContext<RouteHandlers>;

final class HandlerMatch {
  const HandlerMatch({
    required this.path,
    required this.handlers,
    required this.params,
  });

  final String path;
  final RouteHandlers handlers;
  final Map<String, String> params;

  Handler? resolve(HttpMethod method) => resolveHandler(handlers, method);
}

HandlerRouter createHandlerRouter(Map<String, RouteHandlers> routes) {
  final router = createRouter<RouteHandlers>();
  for (final entry in routes.entries) {
    addRoute(router, null, entry.key, Map.unmodifiable(entry.value));
  }
  return router;
}

HandlerMatch? matchHandlerRoute(
  HandlerRouter router, {
  required HttpMethod method,
  required String path,
}) {
  final matched = findRoute(router, null, path);
  if (matched case MatchedRoute<RouteHandlers> route) {
    final handler = resolveHandler(route.data, method);
    if (handler == null) {
      return null;
    }

    return HandlerMatch(
      path: path,
      handlers: route.data,
      params: Map.unmodifiable(route.params ?? const <String, String>{}),
    );
  }

  return null;
}

Handler? resolveHandler(RouteHandlers handlers, HttpMethod method) {
  final exact = handlers[method];
  if (exact != null) {
    return exact;
  }

  if (method == HttpMethod.head) {
    final get = handlers[HttpMethod.get];
    if (get != null) {
      return get;
    }
  }

  return handlers[HttpMethod.any];
}
