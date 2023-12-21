import 'package:routingkit/routingkit.dart';

import '../middleware/middleware.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  /// Creates a new [RoutesBuilder] wrapped in the supplied array of
  /// [Middleware] or paths.
  RoutesBuilder groupd({Iterable<Middleware>? middleware, String? path}) {
    RoutesBuilder current = this;

    if (path != null) {
      current = _PathWrapper(current, path.pathComponents);
    }

    if (middleware?.isNotEmpty == true) {
      current = _MiddlewareWrapper(current, middleware!);
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

class _MiddlewareWrapper implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<Middleware> middleware;

  const _MiddlewareWrapper(this.root, this.middleware);

  @override
  void route(Route route) {
    route.responder = middleware.makeResponder(route.responder);
    root.route(route);
  }
}

class _PathWrapper implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<PathComponent> path;

  const _PathWrapper(this.root, this.path);

  @override
  void route(Route route) {
    route.path = [...path, ...route.path];
    root.route(route);
  }
}
