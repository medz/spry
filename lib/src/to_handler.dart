import 'dart:async';

import 'package:routingkit/routingkit.dart';

import '_constants.dart';
import 'request_utils.dart';
import 'response.dart';
import 'types.dart';
import 'next.dart';

Handler<Response> toHandler(Spry app) {
  return app.stack.reversed.fold(
    _createRouterHandler(app.router),
    (next, current) => (event) {
      event.set(kNext, next);

      return _createResponseWith(event, current(event));
    },
  );
}

Handler<Response> _createRouterHandler(RouterContext<Handler> context) {
  return (event) {
    final request = useRequest(event);
    final route = _lookup(context, request.method, request.uri.path);

    if (route == null) {
      return Response(null, status: 404);
    }

    return _createResponseWith(
      event..set(kParams, route.params),
      route.data(event),
    );
  };
}

MatchedRoute<Handler>? _lookup(
    RouterContext<Handler> context, String method, String path) {
  MatchedRoute<Handler>? findLastRoute(String method) {
    return findRoute(context, method, path)?.lastOrNull;
  }

  return switch (method) {
    'HEAD' => switch (findLastRoute('HEAD')) {
        MatchedRoute<Handler> route => route,
        _ => _lookup(context, 'GET', path),
      },
    String method => switch (findLastRoute(method)) {
        MatchedRoute<Handler> route => route,
        _ => findLastRoute(kAllMethod),
      },
  };
}

Future<Response> _createResponseWith(Event event, FutureOr value) async {
  final response = switch (await value) {
    Response response => response,
    // TODO:
    _ => await next(event),
  };

  return response..headers.set('X-Powered-By', 'spry.fun');
}
