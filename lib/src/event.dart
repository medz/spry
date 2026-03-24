import 'package:ht/ht.dart' show Headers, Request, URLSearchParams;

import '../osrv.dart' show RequestContext;
import 'app.dart';
import 'locals.dart';
import 'params.dart';
import 'websocket.dart';

/// Request-scoped context passed to routes, middleware, and error handlers.
final class Event {
  /// Creates an event for the active request.
  Event({
    required this.app,
    required this.request,
    required this.context,
    RouteParams? params,
    Locals? locals,
    Uri? url,
  }) : params = params ?? RouteParams(<String, String>{}),
       locals = locals ?? Locals(<Symbol, Object?>{}),
       url = url ?? Uri.parse(request.url);

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

  /// Websocket controls and metadata for the active request.
  late final EventWebSocket ws = EventWebSocket(this);

  /// Request headers.
  Headers get headers => request.headers;

  /// Request method.
  String get method => request.method.value;

  /// Request URL.
  final Uri url;

  /// Query parameters for the request URL.
  late final URLSearchParams query = URLSearchParams(url.query);

  /// Request pathname without query parameters.
  String get pathname => url.path;

  /// Request path including the query string when present.
  String get path {
    if (url.hasQuery) {
      return '$pathname?${query.toString()}';
    }

    return pathname;
  }
}
