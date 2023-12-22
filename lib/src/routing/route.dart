import 'package:routingkit/routingkit.dart';

import '../responder/responder.dart';

class Route {
  /// The route method
  final String method;

  /// The route path
  final Iterable<PathComponent> path;

  /// The route responder
  final Responder responder;

  /// The route description
  final String? description;

  /// Creates a new route
  const Route({
    required this.method,
    required this.path,
    required this.responder,
    this.description,
  });

  @override
  String toString() => description ?? '$method $path';
}
