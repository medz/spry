import 'dart:async';

import 'package:ht/ht.dart' show HttpMethod, Response;

import 'event.dart';

typedef Next = Future<Response> Function();
typedef Middleware = FutureOr<Response> Function(Event event, Next next);

final class MiddlewareRoute {
  const MiddlewareRoute({
    required this.path,
    required this.handler,
    this.method,
  });

  final String path;
  final HttpMethod? method;
  final Middleware handler;
}
