import 'http_method.dart';
import 'types.dart';

final class ErrorRoute {
  const ErrorRoute({
    required this.path,
    required this.handler,
    this.method = HttpMethod.any,
  });

  final String path;
  final HttpMethod method;
  final ErrorHandler handler;
}
