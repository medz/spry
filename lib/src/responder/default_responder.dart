import 'dart:async';

import 'package:routingkit/routingkit.dart';
import 'package:webfetch/webfetch.dart';

import '../middleware/middleware.dart';
import '../request/request_event.dart';
import '../routing/route.dart';
import '../routing/routes.dart';
import 'middleware_responder.dart';
import 'responder.dart';

class DefaultResponder implements Responder {
  late final TrieRouter<(Route, Responder)> _router;
  late final Responder _notFoundResponder;

  @override
  FutureOr<Response> respond(RequestEvent event) async {
    final cache = lookup(event);
    if (cache == null) {
      return _notFoundResponder.respond(event);
    }

    final (route, responder) = cache;
    event.container.set<Route>(route);

    final response = await responder.respond(event);
    if (!response.headers.has('x-request-id')) {
      response.headers.set('x-request-id', event.id);
    }

    return response;
  }

  DefaultResponder({
    required Routes routes,
    Iterable<Middleware> middleware = const [],
  }) {
    final options = ConfigurationOptions(caseSensitive: routes.caseSensitive);
    final router = TrieRouter<(Route, Responder)>(options: options);

    for (final route in routes) {
      final responder = middleware.makeResponder(route.responder);

      final pathComponents = route.path.where((element) {
        return switch (element) {
          ConstantPathComponent(constant: final path) => path.isEmpty,
          _ => true,
        };
      });

      // Register the route wrapped the method.
      router.register((
        route,
        responder
      ), [
        PathComponent.constant(route.method.toUpperCase()),
        ...pathComponents
      ]);

      // If the route isn't explicitly a HEAD route,
      // and it's made up solely of .constant components,
      // register a HEAD route with the same path
      if (routes.allowHeadRouteRegistration(route)) {
        final responder = const _DefaultHeadResponder();
        final head = Route(
          method: 'HEAD',
          path: pathComponents,
          responder: responder,
          description: 'HEAD proxy ${route.description}',
        );
        final headResponder = middleware.makeResponder(responder);

        router.register((head, headResponder),
            [const PathComponent.constant('HEAD'), ...pathComponents]);
      }
    }

    _router = router;
    _notFoundResponder =
        middleware.makeResponder(const _DefaultNotFoundResponder());
  }
}

class _DefaultHeadResponder implements Responder {
  const _DefaultHeadResponder();

  @override
  FutureOr<Response> respond(RequestEvent event) => Response(null, status: 200);
}

class _DefaultNotFoundResponder implements Responder {
  const _DefaultNotFoundResponder();

  @override
  FutureOr<Response> respond(RequestEvent event) {
    return Response('Not Found', status: 404);
  }
}

extension on Routes {
  bool allowHeadRouteRegistration(Route route) {
    if (route.method.toUpperCase() != 'GET') return false;
    if (route.path.any((element) => element is! ConstantPathComponent)) {
      return false;
    }

    return true;
  }
}

extension on DefaultResponder {
  (Route, Responder)? lookup(RequestEvent event) {
    String method = event.request.method.toUpperCase();
    final paths = URL(event.request.url).pathname.splitWithSlash();

    // If it's a HEAD request and a HEAD route exists, return that route...
    if (method == 'HEAD') {
      final head = _router.lookup([method, ...paths], event.parameters);
      if (head != null) return head;
    }

    return _router.lookup([
      method == 'HEAD' ? 'GET' : method,
      ...paths,
    ], event.parameters);
  }
}
