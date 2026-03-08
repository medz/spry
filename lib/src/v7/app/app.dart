import '../../http/request.dart';
import '../../http/response.dart';
import '../routing/error_collector.dart';
import '../routing/error_route.dart';
import '../routing/handler_matcher.dart';
import '../routing/http_method.dart';
import '../routing/middleware_collector.dart';
import '../routing/middleware_route.dart';
import 'app_context.dart';
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

  Future<Response> fetch(Request request) {
    throw UnimplementedError('Spry v7 fetch() is not implemented yet.');
  }
}
