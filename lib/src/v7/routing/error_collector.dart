import 'error_route.dart';
import 'http_method.dart';
import 'path_pattern_matcher.dart';

typedef ErrorRouter = List<_ErrorEntry>;

final class ErrorMatch {
  const ErrorMatch({required this.route, required this.params});

  final ErrorRoute route;
  final Map<String, String> params;
}

final class _ErrorEntry {
  const _ErrorEntry({required this.route, required this.order});

  final ErrorRoute route;
  final int order;
}

final class _ResolvedErrorMatch {
  const _ResolvedErrorMatch({
    required this.route,
    required this.params,
    required this.order,
  });

  final ErrorRoute route;
  final Map<String, String> params;
  final int order;
}

ErrorRouter createErrorRouter(List<ErrorRoute> routes) {
  return List.unmodifiable([
    for (final (index, route) in routes.indexed)
      _ErrorEntry(route: route, order: index),
  ]);
}

List<ErrorMatch> collectErrorRoutes(
  ErrorRouter router, {
  required HttpMethod method,
  required String path,
}) {
  final matches = <_ResolvedErrorMatch>[];

  for (final entry in router) {
    if (!_matchesMethod(entry.route.method, method)) {
      continue;
    }

    final matched = matchPathPattern(entry.route.path, path);
    if (matched == null) {
      continue;
    }

    matches.add(
      _ResolvedErrorMatch(
        route: entry.route,
        params: matched.params,
        order: entry.order,
      ),
    );
  }

  matches.sort(_compareErrorEntry);

  return List.unmodifiable(
    matches.map(
      (match) => ErrorMatch(route: match.route, params: match.params),
    ),
  );
}

int _compareErrorEntry(_ResolvedErrorMatch a, _ResolvedErrorMatch b) {
  final specificityCompare = _specificityScore(
    b.route.path,
  ).compareTo(_specificityScore(a.route.path));
  if (specificityCompare != 0) {
    return specificityCompare;
  }

  final methodCompare = _methodWeight(
    b.route.method,
  ).compareTo(_methodWeight(a.route.method));
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
