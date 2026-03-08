import 'http_method.dart';
import 'middleware_route.dart';
import 'path_pattern_matcher.dart';

typedef MiddlewareRouter = List<_MiddlewareEntry>;

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

final class _ResolvedMiddlewareMatch {
  const _ResolvedMiddlewareMatch({
    required this.route,
    required this.params,
    required this.order,
  });

  final MiddlewareRoute route;
  final Map<String, String> params;
  final int order;
}

MiddlewareRouter createMiddlewareRouter(List<MiddlewareRoute> routes) {
  return List.unmodifiable([
    for (final (index, route) in routes.indexed)
      _MiddlewareEntry(route: route, order: index),
  ]);
}

List<MiddlewareMatch> collectMiddlewareRoutes(
  MiddlewareRouter router, {
  required HttpMethod method,
  required String path,
}) {
  final matches = <_ResolvedMiddlewareMatch>[];

  for (final entry in router) {
    if (!_matchesMethod(entry.route.method, method)) {
      continue;
    }

    final matched = matchPathPattern(entry.route.path, path);
    if (matched == null) {
      continue;
    }

    matches.add(
      _ResolvedMiddlewareMatch(
        route: entry.route,
        params: matched.params,
        order: entry.order,
      ),
    );
  }

  matches.sort(_compareMiddlewareEntry);

  return List.unmodifiable(
    matches.map(
      (match) => MiddlewareMatch(route: match.route, params: match.params),
    ),
  );
}

int _compareMiddlewareEntry(
  _ResolvedMiddlewareMatch a,
  _ResolvedMiddlewareMatch b,
) {
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
    if (segment == '*') {
      continue;
    }
    if (segment.startsWith(':')) {
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

bool _matchesMethod(HttpMethod entryMethod, HttpMethod requestMethod) {
  return entryMethod == HttpMethod.any || entryMethod == requestMethod;
}
