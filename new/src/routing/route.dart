import 'package:routingkit/routingkit.dart';

import '../responder/responder.dart';

class Route<T, R> {
  final String method;
  Iterable<PathComponent> path;
  Responder responder;
  final userinfo = <Symbol, dynamic>{};

  Route({
    required this.method,
    required this.path,
    required this.responder,
  });

  Route<T, R> describe(String description) {
    userinfo[#description] = description;

    return this;
  }

  String get description {
    final String? existing = userinfo[#description];
    if (existing != null) return existing;

    return '$method /${path.description}';
  }
}
