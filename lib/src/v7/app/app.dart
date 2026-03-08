import '../../http/request.dart';
import '../../http/response.dart';
import '../routing/error_route.dart';
import '../routing/middleware_route.dart';
import 'app_context.dart';
import 'types.dart';

final class Spry implements AppContext {
  const Spry({
    this.routes = const {},
    this.middleware = const [],
    this.errors = const [],
    this.fallback,
  });

  final Map<String, RouteHandlers> routes;
  final List<MiddlewareRoute> middleware;
  final List<ErrorRoute> errors;
  final RouteHandlers? fallback;

  Future<Response> fetch(Request request) {
    throw UnimplementedError('Spry v7 fetch() is not implemented yet.');
  }
}
