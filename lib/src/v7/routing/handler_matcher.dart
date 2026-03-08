import 'package:roux/roux.dart';

import '../app/types.dart';
import 'http_method.dart';

final class HandlerRouter {
  HandlerRouter._(this._router);

  final Router<_HandlerEntry> _router;
}

final class HandlerMatch {
  const HandlerMatch({
    required this.path,
    required this.handler,
    required this.method,
    required this.params,
  });

  final String path;
  final Handler handler;
  final HttpMethod method;
  final Map<String, String> params;
}

HandlerRouter createHandlerRouter(Map<String, RouteHandlers> routes) {
  final router = Router<_HandlerEntry>();

  for (final route in routes.entries) {
    for (final methodHandler in route.value.entries) {
      final entry = _HandlerEntry(
        path: route.key,
        method: methodHandler.key,
        handler: methodHandler.value,
      );

      router.add(route.key, entry, method: methodHandler.key.routerToken);
    }
  }

  return HandlerRouter._(router);
}

HandlerMatch? matchHandlerRoute(
  HandlerRouter router, {
  required HttpMethod method,
  required String path,
}) {
  if (method == HttpMethod.head) {
    final head = _matchInRouter(router._router, path, HttpMethod.head);
    if (head != null && head.method == HttpMethod.head) {
      return head;
    }

    final get = _matchInRouter(router._router, path, HttpMethod.get);
    if (get != null) {
      return get;
    }

    return head;
  }

  return _matchInRouter(router._router, path, method);
}

HandlerMatch? _matchInRouter(
  Router<_HandlerEntry> router,
  String path,
  HttpMethod method,
) {
  final matched = router.match(path, method: method.routerToken);
  if (matched == null) {
    return null;
  }

  return HandlerMatch(
    path: matched.data.path,
    handler: matched.data.handler,
    method: matched.data.method,
    params: Map.unmodifiable(matched.params ?? const <String, String>{}),
  );
}

final class _HandlerEntry {
  const _HandlerEntry({
    required this.path,
    required this.method,
    required this.handler,
  });

  final String path;
  final HttpMethod method;
  final Handler handler;
}
