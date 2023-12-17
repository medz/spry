import 'package:routingkit/routingkit.dart';

import '../middleware/middleware.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  void group(void Function(RoutesBuilder) configure,
          {String? path, Iterable<Middleware>? middleware}) =>
      configure(grouped(path: path, middleware: middleware));

  RoutesBuilder grouped({String? path, Iterable<Middleware>? middleware}) {
    RoutesBuilder current = this;

    // If we have provided path, we need to create a new group.
    if (path != null) {
      current = _RoutesGroup(this, path.pathComponents);
    }

    // If we have provided middleware, we need to create a new group.
    if (middleware != null) {
      current = _MiddlewareGroup(current, middleware);
    }

    return current;
  }
}

class _RoutesGroup implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<PathComponent> path;

  const _RoutesGroup(this.root, this.path);

  @override
  void add(Route child) {
    final route = Route(
      method: child.method,
      path: path.followedBy(child.path), // [1], [2] -> [1, 2]
      responder: child.responder,
      description: child.description,
    );

    root.add(route);
  }
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
