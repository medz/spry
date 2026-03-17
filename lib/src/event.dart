import 'package:ht/ht.dart' show Headers, Request, URLSearchParams;
import 'package:osrv/osrv.dart' show RequestContext;

import 'app.dart';
import 'locals.dart';
import 'params.dart';

/// Request-scoped context passed to routes, middleware, and error handlers.
final class Event {
  /// Creates an event for the active request.
  Event({
    required this.app,
    required this.request,
    required this.context,
    RouteParams? params,
    Locals? locals,
  }) : params = params ?? RouteParams(<String, String>{}),
       locals = locals ?? Locals(<Symbol, Object?>{});

  /// Application instance handling the request.
  final Spry app;

  /// Incoming request.
  final Request request;

  /// Runtime request context.
  final RequestContext context;

  /// Route parameters extracted from the matched route.
  final RouteParams params;

  /// Per-request local storage shared across handlers.
  final Locals locals;

  /// Request headers.
  Headers get headers => request.headers;

  /// Request method.
  String get method => request.method.value;

  /// Request URL.
  Uri get url => Uri.parse(request.url);

  /// Request pathname without query parameters.
  String get pathname => url.path;

  /// Request path including the query string when present.
  String get path {
    if (url.hasQuery) {
      return '$pathname?${query.toString()}';
    }

    return pathname;
  }

  /// Query parameters for the request URL.
  URLSearchParams get query => URLSearchParams(url.query);
}
