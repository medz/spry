import '../app/types.dart';
import 'http_method.dart';

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
