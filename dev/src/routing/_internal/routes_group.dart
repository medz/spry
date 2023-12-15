import 'package:routingkit/routingkit.dart';

import '../route.dart';
import '../routes_builder.dart';

class RoutesGroup implements RoutesBuilder {
  final RoutesBuilder root;
  final Iterable<PathComponent> path;

  const RoutesGroup(this.root, this.path);

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
