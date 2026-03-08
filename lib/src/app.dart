import 'package:osrv/osrv.dart';
import 'package:roux/roux.dart';

import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';
import 'routing/handlers.dart';

final class Spry {
  Spry({
    this.routes = const {},
    this.middleware = const [],
    this.errors = const [],
    this.fallback,
  });

  final Map<String, RouteHandlers> routes;
  final List<MiddlewareRoute> middleware;
  final List<ErrorRoute> errors;
  final RouteHandlers? fallback;

  late final Router<Handler> handlers = createHandlerRouter(routes);

  Future<Response> fetch(Request request, RequestContext context) async {
    throw UnimplementedError('Spry v7 fetch() is not implemented yet.');
  }
}
