import 'types.dart';

final class MiddlewareRoute {
  const MiddlewareRoute({
    required this.path,
    required this.handler,
    this.method,
  });

  final String path;
  final String? method;
  final Middleware handler;
}
