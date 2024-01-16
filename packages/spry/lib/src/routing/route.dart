import 'package:routingkit/routingkit.dart';

import '../handler/handler.dart';

class Route<T> {
  final String method;
  final Iterable<Segment> segments;
  final Handler<T> handler;

  const Route({
    required this.method,
    required this.segments,
    required this.handler,
  });

  Route<T> copyWith({
    String? method,
    Iterable<Segment>? path,
    Handler<T>? handler,
  }) {
    return Route(
      method: method ?? this.method,
      segments: path ?? this.segments,
      handler: handler ?? this.handler,
    );
  }
}
