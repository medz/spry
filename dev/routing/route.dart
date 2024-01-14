import 'package:routingkit/routingkit.dart';

import '../handler/handler.dart';

class Route {
  final String method;
  final Iterable<Segment> path;
  final Handler handler;

  const Route({
    required this.method,
    required this.path,
    required this.handler,
  });

  Route copyWith({
    String? method,
    Iterable<Segment>? path,
    Handler? handler,
  }) {
    return Route(
      method: method ?? this.method,
      path: path ?? this.path,
      handler: handler ?? this.handler,
    );
  }
}
