import 'package:routingkit/routingkit.dart';

import '../middleware/middleware.dart';
import '../responder/middleware_responder.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  /// Creates a new [RoutesBuilder] wrapped in the supplied array of
  /// [Middleware] or paths.
  RoutesBuilder groupd({Iterable<Middleware>? middleware, String? path}) {
    assert(
      (middleware == null || middleware.isEmpty) &&
          (path == null || path.isEmpty),
      'Middleware or path must is not empty.',
    );

    RoutesBuilder current = this;

    if (path != null) {
      current = _PathGroupedRoutesBuilder(current, path.pathComponents);
    }

    if (middleware != null && middleware.isNotEmpty) {
      current = _MiddlewareGroupedRoutesBuilder(current, middleware);
    }

    return current;
  }

  /// Closure for creating a new [RoutesBuilder] wrapped in the supplied array
  /// of [Middleware] or paths.
  void group(
    void Function(RoutesBuilder routes) configure, {
    Iterable<Middleware>? middleware,
    String? path,
  }) =>
      configure(groupd(middleware: middleware, path: path));
}

class _MiddlewareGroupedRoutesBuilder implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<Middleware> middleware;

  const _MiddlewareGroupedRoutesBuilder(this.root, this.middleware);

  @override
  void addRoute(Route route) {
    final wrappedRoute = Route(
      method: route.method,
      path: route.path,
      responder: middleware.makeResponder(route.responder),
    );

    return root.addRoute(wrappedRoute);
  }
}

class _PathGroupedRoutesBuilder implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<PathComponent> path;

  const _PathGroupedRoutesBuilder(this.root, this.path);

  @override
  void addRoute(Route route) {
    final wrappedRoute = Route(
      method: route.method,
      path: [...path, ...route.path],
      responder: route.responder,
    );
    return root.addRoute(wrappedRoute);
  }
}
