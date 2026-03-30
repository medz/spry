import 'package:ht/ht.dart' show HttpMethod, Request, Response;
import 'package:roux/roux.dart';

import '../osrv.dart' show RequestContext;
import 'errors.dart';
import 'event.dart';
import 'error_route.dart';
import 'handler.dart';
import 'middleware.dart';
import 'params.dart';
import 'public/public.dart';
import 'routing.dart';

/// A Spry application with routes, middleware, and error handlers.
final class Spry {
  /// Creates an application from route, middleware, and error definitions.
  Spry({
    Map<String, RouteHandlers> routes = const {},
    Iterable<MiddlewareRoute> middleware = const [],
    Iterable<ErrorRoute> errors = const [],
    this.fallback,
    this.caseSensitive = true,
    this.handlerCacheCapacity,
    String? publicDir,
  }) : router = createHandlerRouter(
         routes,
         caseSensitive: caseSensitive,
         cacheCapacity: _validateHandlerCacheCapacity(handlerCacheCapacity),
       ),
       middleware = createMiddlewareRouter(
         middleware,
         caseSensitive: caseSensitive,
       ),
       errors = createErrorRouter(errors, caseSensitive: caseSensitive),
       publicDir = normalizePublicDir(publicDir);

  /// Route handler router.
  final Router<Handler> router;

  /// Middleware router.
  final Router<Middleware> middleware;

  /// Error handler router.
  final Router<ErrorHandler> errors;

  /// Optional fallback handlers.
  final RouteHandlers? fallback;

  /// Whether route matching treats letter case as significant.
  final bool caseSensitive;

  /// Optional LRU cache capacity for route handler lookups.
  final int? handlerCacheCapacity;

  /// Normalized public asset directory.
  final String? publicDir;

  /// Handles a request by serving public assets, then middleware and routes.
  Future<Response> fetch(Request request, RequestContext context) async {
    final requestUri = Uri.parse(request.url);
    final public = await servePublicAsset(
      request,
      context,
      publicDir: publicDir,
      requestUri: requestUri,
    );
    if (public != null) {
      return public;
    }
    final path = requestUri.path;
    final method = request.method;
    final handlerMatch = matchHandler(router, path, method.value);
    final fallbackHandler = switch (method) {
      HttpMethod.head =>
        fallback?[HttpMethod.head] ??
            fallback?[HttpMethod.get] ??
            fallback?[null],
      _ => fallback?[method] ?? fallback?[null],
    };
    final event = Event(
      app: this,
      request: request,
      context: context,
      params: RouteParams(handlerMatch?.params ?? const {}),
      url: requestUri,
    );

    Future<Response> runRouteHandler() async {
      if (handlerMatch == null && fallbackHandler == null) {
        throw NotFoundError(method: method.value, path: path);
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
            in errors
                .findAll(path, method: method.value, includeAny: true)
                .reversed) {
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
    for (final RouteMatch(data: currentMiddleware)
        in middleware
            .findAll(path, method: method.value, includeAny: true)
            .reversed) {
      final previous = next;
      next = () async => await currentMiddleware(event, previous);
    }

    return next();
  }
}

int? _validateHandlerCacheCapacity(int? value) => switch (value) {
  null => null,
  > 0 => value,
  _ => throw ArgumentError.value(
    value,
    'handlerCacheCapacity',
    'must be a positive integer',
  ),
};
