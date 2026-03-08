import 'package:roux/roux.dart';

import '../handler.dart';

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
