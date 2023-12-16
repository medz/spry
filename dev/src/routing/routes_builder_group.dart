import 'package:routingkit/routingkit.dart';

import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  void group(String path, void Function(RoutesBuilder) configure) =>
      configure(grouped(path));

  RoutesBuilder grouped(String path) => _RoutesGroup(this, path.pathComponents);
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
