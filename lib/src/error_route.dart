import 'types.dart';
import 'http_method.dart';

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
