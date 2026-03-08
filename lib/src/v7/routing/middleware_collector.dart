import 'package:routingkit/routingkit.dart';

import 'http_method.dart';
import 'middleware_route.dart';

typedef MiddlewareRouter = RouterContext<_MiddlewareEntry>;

final class MiddlewareMatch {
  const MiddlewareMatch({required this.route, required this.params});

  final MiddlewareRoute route;
  final Map<String, String> params;
}

final class _MiddlewareEntry {
  const _MiddlewareEntry({required this.route, required this.order});

  final MiddlewareRoute route;
  final int order;
}

MiddlewareRouter createMiddlewareRouter(List<MiddlewareRoute> routes) {
  final router = createRouter<_MiddlewareEntry>();
  for (final (index, route) in routes.indexed) {
    addRoute(
      router,
      route.method.routerToken,
      route.path,
      _MiddlewareEntry(route: route, order: index),
    );
  }
  return router;
}

List<MiddlewareMatch> collectMiddlewareRoutes(
  MiddlewareRouter router, {
  required HttpMethod method,
  required String path,
}) {
  final matches = <MatchedRoute<_MiddlewareEntry>>[
    ...findAllRoutes(router, HttpMethod.any.routerToken, path),
    if (method != HttpMethod.any)
      ...findAllRoutes(router, method.routerToken, path),
  ];

  matches.sort((a, b) => _compareMiddlewareEntry(a.data, b.data));

  return List.unmodifiable(matches.map(_toMiddlewareMatch));
}

MiddlewareMatch _toMiddlewareMatch(MatchedRoute<_MiddlewareEntry> matched) {
  return MiddlewareMatch(
    route: matched.data.route,
    params: Map.unmodifiable(matched.params ?? const <String, String>{}),
  );
}

int _compareMiddlewareEntry(_MiddlewareEntry a, _MiddlewareEntry b) {
  final specificityCompare = _specificityScore(
    a.route.path,
  ).compareTo(_specificityScore(b.route.path));
  if (specificityCompare != 0) {
    return specificityCompare;
  }

  final methodCompare = _methodWeight(
    a.route.method,
  ).compareTo(_methodWeight(b.route.method));
  if (methodCompare != 0) {
    return methodCompare;
  }

  return a.order.compareTo(b.order);
}

int _specificityScore(String path) {
  final segments = path.split('/').where((segment) => segment.isNotEmpty);

  var score = 0;
  for (final segment in segments) {
    if (segment.startsWith('**')) {
      continue;
    }
    if (segment == '*' || segment.startsWith(':')) {
      score += 2;
      continue;
    }
    score += 4;
  }
  return score;
}

int _methodWeight(HttpMethod method) => switch (method) {
  HttpMethod.any => 0,
  _ => 1,
};
