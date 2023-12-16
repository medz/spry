import '../middleware/middleware.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderMiddleware on RoutesBuilder {
  /// Creates a new [RoutesBuilder] that will apply the given [middleware] to
  /// all routes added to it.
  RoutesBuilder middlewared(Iterable<Middleware> middleware) =>
      _MiddlewareGroup(this, middleware);

  /// Using closures, we can create a new [RoutesBuilder] that will apply the
  /// given [middleware] to all routes added to it.
  void middleware(Iterable<Middleware> middleware,
          void Function(RoutesBuilder) configure) =>
      configure(middlewared(middleware));
}

class _MiddlewareGroup implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<Middleware> middleware;

  const _MiddlewareGroup(this.root, this.middleware);

  @override
  void add(Route child) {
    final route = Route(
      method: child.method,
      path: child.path,
      responder: middleware.makeResponder(child.responder),
      description: child.description,
    );

    root.add(route);
  }
}
