import '../application.dart';
import 'middleware.dart';

enum MiddlewarePosition { before, after }

class MiddlewareConfiguration {
  final List<Middleware> _storage = [];

  /// Adds a pre-initialized [Middleware] instance.
  ///
  /// ```dart
  /// app.middleware.use(LoggerMiddleware());
  /// ```
  void use(
    Middleware middleware, {
    MiddlewarePosition position = MiddlewarePosition.after,
  }) {
    switch (position) {
      case MiddlewarePosition.before:
        _storage.insert(0, middleware);
        break;
      case MiddlewarePosition.after:
        _storage.add(middleware);
        break;
    }
  }

  /// Resolves the configured middleware for a given container.
  Iterable<Middleware> resolve() => _storage;
}

extension ApplicationMiddlewareConfiguration on Application {
  MiddlewareConfiguration get middleware =>
      injectOrProvide(MiddlewareConfiguration, MiddlewareConfiguration.new);
}
