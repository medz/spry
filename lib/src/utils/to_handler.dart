import 'package:routingkit/routingkit.dart';

import '../_constants.dart';
import '../http/response.dart';
import '../types.dart';
import '_create_response_with.dart';
import 'request_utils.dart';

/// Creates a new Spry [Handler] using a [Spry] application.
Handler<Response> toHandler(Spry app) {
  final handler = app.stack.reversed.fold(
    _createRouterHandler(app.router),
    (next, current) => (event) {
      event.set(kNext, next);

      return current(event);
    },
  );

  return (event) => createResponseWith(event, handler(event));
}

Handler _createRouterHandler(Router<Handler> router) {
  return (event) {
    final request = useRequest(event);
    final route = _lookup(router, request.method, request.uri.path);

    if (route == null) {
      return Response(null, status: 404);
    }

    event.set(kParams, route.params);

    return route.data(event);
  };
}

MatchedRoute<Handler>? _lookup(
    Router<Handler> router, String method, String path) {
  MatchedRoute<Handler>? findRoute(String? method) {
    return router.find(method, path);
  }

  return switch (method) {
    'HEAD' => switch (findRoute('HEAD')) {
        MatchedRoute<Handler> route => route,
        _ => _lookup(router, 'GET', path),
      },
    String method => switch (findRoute(method)) {
        MatchedRoute<Handler> route => route,
        _ => findRoute(null),
      },
  };
}
