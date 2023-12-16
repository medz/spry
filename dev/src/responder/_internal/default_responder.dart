import 'dart:async';

import 'package:routingkit/routingkit.dart';

import '../../http/responder.dart';
import '../../middleware/middleware.dart';
import '../../polyfills/standard_web_polyfills.dart';
import '../../request/request_event.dart';
import '../../routing/route.dart';
import '../../routing/routes.dart';

class DefaultResponder implements Responder {
  final TrieRouter<CachedRoute> router;
  final Responder notFoundResponder;

  const DefaultResponder._(this.router, this.notFoundResponder);

  factory DefaultResponder({
    required Routes routes,
    Iterable<Middleware> middleware = const [],
  }) {
    final options = ConfigurationOptions(caseSensitive: routes.caseInsensitive);
    final router = TrieRouter<CachedRoute>(options: options);

    for (final route in routes.all) {
      final responder = middleware.makeResponder(route.responder);
      final cache = CachedRoute(route, responder);

      // Remove any empty path components.
      final path = route.path.where((component) {
        return switch (component) {
          ConstantPathComponent(constant: final segment) => segment.isNotEmpty,
          _ => true,
        };
      });

      // If the route isn't explicitly a HEAD route, and it's made up solely of
      // constant path components, register a HEAD route with the same path.
      if (route.allowRegisterHeadRoute(routes, options.caseSensitive)) {
        final headRoute = Route(
          method: 'head',
          path: route.path,
          responder: middleware.makeResponder(const HeadResponder()),
        );
        final cacheHeadRoute = CachedRoute(headRoute, headRoute.responder);

        router.register(cacheHeadRoute, [
          PathComponent.constant(headRoute.method),
          ...path,
        ]);
      }

      router.register(cache, {
        PathComponent.constant(route.method.toLowerCase()),
        ...path,
      });
    }

    return DefaultResponder._(
      router,
      middleware.makeResponder(const NotFoundResponder()),
    );
  }

  @override
  Future<Response> respond(RequestEvent event) async {
    FutureOr<Response> respond(CachedRoute cache) {
      event.provide(Route, () => cache.route);

      return cache.responder.respond(event);
    }

    return switch (routeFor(event)) {
      CachedRoute cache => respond(cache),
      _ => notFoundResponder.respond(event),
    };
  }

  /// Returns the [CachedRoute] for the given [event], or `null` if no route
  /// matches.
  CachedRoute? routeFor(RequestEvent event) {
    final path = URL(event.request.url).pathname.splitWithSlash();

    if (event.request.method.toLowerCase() == 'head') {
      final route = router.lookup(['head', ...path], event.parameters);
      if (route != null) return route;
    }

    final method = event.request.method.toLowerCase() == 'head'
        ? 'get'
        : event.request.method.toLowerCase();

    return router.lookup([method, ...path], event.parameters);
  }
}

class CachedRoute {
  final Route route;
  final Responder responder;

  const CachedRoute(this.route, this.responder);
}

class HeadResponder implements Responder {
  const HeadResponder();

  @override
  FutureOr<Response> respond(RequestEvent event) {
    return Response(null);
  }
}

class NotFoundResponder implements Responder {
  const NotFoundResponder();

  @override
  FutureOr<Response> respond(RequestEvent event) {
    return Response(null, status: 404);
  }
}

extension on Route {
  bool allowRegisterHeadRoute(Routes routes, bool caseSensitive) {
    if (method.toLowerCase() != 'get') return false;
    if (path.any((element) => element is! ConstantPathComponent)) {
      return false;
    }

    final currentRoutePath =
        caseSensitive ? path.path : path.path.toLowerCase();
    final registed = routes.all.any((element) {
      final path =
          caseSensitive ? element.path.path : element.path.path.toLowerCase();

      return element.method.toLowerCase() == 'head' && path == currentRoutePath;
    });

    return !registed;
  }
}
