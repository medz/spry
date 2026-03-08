import 'http/request.dart';
import 'http/response.dart';
import 'error_collector.dart';
import 'error_route.dart';
import 'handler_matcher.dart';
import 'http_method.dart';
import 'middleware_collector.dart';
import 'middleware_route.dart';
import 'app_context.dart';
import 'event.dart';
import 'response_resolver.dart';
import 'types.dart';

final class Spry implements AppContext {
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

  late final HandlerRouter handlerRouter = createHandlerRouter(routes);
  late final MiddlewareRouter middlewareRouter = createMiddlewareRouter(
    middleware,
  );
  late final ErrorRouter errorRouter = createErrorRouter(errors);

  HandlerMatch? matchHandler(Request request) {
    return matchHandlerRoute(
      handlerRouter,
      method: HttpMethodLookup.fromRequestMethod(request.method),
      path: request.url.path,
    );
  }

  List<MiddlewareMatch> collectMiddleware(Request request) {
    return collectMiddlewareRoutes(
      middlewareRouter,
      method: HttpMethodLookup.fromRequestMethod(request.method),
      path: request.url.path,
    );
  }

  List<ErrorMatch> collectErrors(Request request) {
    return collectErrorRoutes(
      errorRouter,
      method: HttpMethodLookup.fromRequestMethod(request.method),
      path: request.url.path,
    );
  }

  Future<Response> fetch(Request request) async {
    final method = HttpMethodLookup.fromRequestMethod(request.method);
    final handler = matchHandler(request) ?? _matchFallback(method);
    if (handler == null) {
      return Response(null, status: 404);
    }

    final event = Event(app: this, request: request);
    final middlewareMatches = collectMiddleware(request);
    final errorMatches = collectErrors(request);

    Future<Response> runHandler() async {
      _setParams(event, handler.params);
      return await resolveResponse(event, handler.handler(event));
    }

    var respond = runHandler;
    for (final match in middlewareMatches.reversed) {
      final prev = respond;
      respond = () async {
        _setParams(event, match.params);
        return await match.route.handler(event, prev);
      };
    }

    try {
      return await respond();
    } catch (error, stack) {
      return await _handleError(event, error, stack, errorMatches);
    }
  }

  HandlerMatch? _matchFallback(HttpMethod method) {
    final handlers = fallback;
    if (handlers == null) {
      return null;
    }

    final handler = _resolveFallbackHandler(handlers, method);
    if (handler == null) {
      return null;
    }

    return HandlerMatch(
      path: '/*',
      handler: handler.$2,
      method: handler.$1,
      params: const {},
    );
  }

  (HttpMethod, Handler)? _resolveFallbackHandler(
    RouteHandlers handlers,
    HttpMethod method,
  ) {
    final exact = handlers[method];
    if (exact != null) {
      return (method, exact);
    }

    if (method == HttpMethod.head) {
      final get = handlers[HttpMethod.get];
      if (get != null) {
        return (HttpMethod.get, get);
      }
    }

    final any = handlers[HttpMethod.any];
    if (any != null) {
      return (HttpMethod.any, any);
    }

    return null;
  }

  Future<Response> _handleError(
    Event event,
    Object error,
    StackTrace stack,
    List<ErrorMatch> matches,
  ) async {
    var currentError = error;
    var currentStack = stack;

    for (final match in matches) {
      try {
        _setParams(event, match.params);
        return await resolveResponse(
          event,
          match.route.handler(currentError, currentStack, event),
        );
      } catch (nextError, nextStack) {
        currentError = nextError;
        currentStack = nextStack;
      }
    }

    return Response(null, status: 500);
  }
}

void _setParams(Event event, Map<String, String> params) {
  event.params
    ..clear()
    ..addAll(params);
}
