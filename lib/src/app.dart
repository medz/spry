import 'package:osrv/osrv.dart';
import 'package:roux/roux.dart';

import 'event.dart';
import 'error_route.dart';
import 'handler.dart';
import 'http_error.dart';
import 'middleware.dart';
import 'routing/errors.dart';
import 'routing/handlers.dart';
import 'routing/middleware.dart';
import 'routing/params.dart';

final class NotFoundError extends HTTPError {
  const NotFoundError({required this.method, required this.path}) : super(404);

  final String method;
  final String path;
}

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
    final path = request.url.path;
    final method = request.method;
    final handlerMatch = matchHandler(router, path, method);
    final fallbackHandler = switch (method) {
      'HEAD' => fallback?['HEAD'] ?? fallback?['GET'] ?? fallback?[null],
      _ => fallback?[method] ?? fallback?[null],
    };

    final event = Event(
      request: request,
      context: context,
      params: RouteParams(handlerMatch?.params ?? {}),
    );

    Future<Response> invokeHandler() async {
      if (handlerMatch == null && fallbackHandler == null) {
        throw NotFoundError(method: method, path: path);
      }

      final handler = handlerMatch?.data ?? fallbackHandler!;
      return await handler(event);
    }

    Future<Response> invokeWithErrors() async {
      try {
        return await invokeHandler();
      } catch (error, stackTrace) {
        var currentError = error;
        var currentStackTrace = stackTrace;

        for (final match in collectErrors(errors, path, method)) {
          try {
            return await match.data.handler(
              currentError,
              currentStackTrace,
              event,
            );
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

    Next next = invokeWithErrors;
    for (final match in middleware.matchAll(path, method: method).reversed) {
      final current = match.data;
      final previous = next;
      next = () async => await current.handler(event, previous);
    }

    return next();
  }
}
