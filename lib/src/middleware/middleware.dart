import 'dart:io';

/// Middleware next callback function.
typedef Next = Future<void> Function();

abstract interface class Middleware {
  /// Processes the [request] and calls the [next] middleware.
  Future<void> process(HttpRequest request, Next next);
}
