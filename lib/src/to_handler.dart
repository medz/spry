import 'dart:async';

import 'package:routingkit/routingkit.dart';

import '_constants.dart';
import 'response.dart';
import 'types.dart';
import 'next.dart';
import 'use_request.dart';

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
    final route =
        findRoute(context, request.method, request.uri.path)?.lastOrNull;
    if (route == null) {
      return Response(null, status: 404);
    }

    return _createResponseWith(
      event..set(kParams, route.params),
      route.data(event),
    );
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
