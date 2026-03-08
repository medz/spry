import 'http_method.dart';
import 'types.dart';

final class MiddlewareRoute {
  const MiddlewareRoute({
    required this.path,
    required this.handler,
    this.method = HttpMethod.any,
  });

  final String path;
  final HttpMethod method;
  final Middleware handler;
}
