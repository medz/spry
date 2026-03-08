import 'handler.dart';

final class ErrorRoute {
  const ErrorRoute({required this.path, required this.handler, this.method});

  final String path;
  final String? method;
  final ErrorHandler handler;
}
