import 'package:ht/ht.dart' show HttpMethod;

import 'handler.dart';

/// Binds an error handler to a route path and optional method.
final class ErrorRoute {
  /// Creates an error route binding.
  const ErrorRoute({required this.path, required this.handler, this.method});

  /// Path pattern matched by the error handler.
  final String path;

  /// Optional HTTP method restriction.
  final HttpMethod? method;

  /// Error handler implementation.
  final ErrorHandler handler;
}
