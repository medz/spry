import 'package:osrv/osrv.dart';
import 'package:roux/roux.dart';

import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';
import 'routing/errors.dart';
import 'routing/handlers.dart';
import 'routing/middleware.dart';

final class Spry {
  Spry({
    Map<String, RouteHandlers> routes = const {},
    Iterable<MiddlewareRoute> middleware = const [],
    Iterable<ErrorRoute> errors = const [],
    this.fallback,
  }) : router = createHandlerRouter(routes),
       middleware = createMiddlewareRouter(middleware),
       errors = createErrorRouter(errors);

  final Router<Handler> router;
  final Router<MiddlewareRoute> middleware;
  final Router<ErrorRoute> errors;
  final RouteHandlers? fallback;

  Future<Response> fetch(Request request, RequestContext context) async {
    throw UnimplementedError('Spry v7 fetch() is not implemented yet.');
  }
}
