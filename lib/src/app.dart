import 'package:osrv/osrv.dart';
import 'package:roux/roux.dart';

import 'errors.dart';
import 'event.dart';
import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';
import 'params.dart';
import 'routing.dart';

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
  final Router<Middleware> middleware;
  final Router<ErrorHandler> errors;
  final RouteHandlers? fallback;

  Future<Response> fetch(Request request, RequestContext context) async {
    final path = request.url.path;
    final method = request.method;
    final handlerMatch = matchHandler(router, path, method);
    final fallbackHandler = switch (method) {
      'HEAD' => fallback?['HEAD'] ?? fallback?['GET'] ?? fallback?[null],
      _ => fallback?[method] ?? fallback?[null],
    };

    final event = Event(
      app: this,
      request: request,
      context: context,
      params: RouteParams(handlerMatch?.params ?? {}),
    );

    Future<Response> runRouteHandler() async {
      if (handlerMatch == null && fallbackHandler == null) {
        throw NotFoundError(method: method, path: path);
      }

      final handler = handlerMatch?.data ?? fallbackHandler!;
      return await handler(event);
    }

    Future<Response> runErrorHandlers() async {
      try {
        return await runRouteHandler();
      } catch (error, stackTrace) {
        var currentError = error;
        var currentStackTrace = stackTrace;

        for (final RouteMatch(data: errorHandler)
            in errors.matchAll(path, method: method).reversed) {
          try {
            return await errorHandler(currentError, currentStackTrace, event);
          } catch (nextError, nextStackTrace) {
            currentError = nextError;
            currentStackTrace = nextStackTrace;
          }
        }

        if (currentError case HTTPError()) {
          return currentError.toResponse();
        }

        Error.throwWithStackTrace(currentError, currentStackTrace);
      }
    }

    Next next = runErrorHandlers;
    for (final RouteMatch(data: middleware)
        in middleware.matchAll(path, method: method).reversed) {
      final previous = next;
      next = () async => await middleware(event, previous);
    }

    return next();
  }
}
