import 'package:routingkit/routingkit.dart';

import '../responder/responder.dart';

class Route<T> {
  final String method;
  Iterable<PathComponent> path;
  Responder responder;
  final userinfo = <Symbol, dynamic>{};

  Route({
    required this.method,
    required this.path,
    required this.responder,
    String? description,
  }) {
    if (description != null) {
      userinfo[#description] = description;
    }
  }

  String get description {
    final String? existing = userinfo[#description];
    if (existing != null) return existing;

    return '$method /${path.description}';
  }
}
