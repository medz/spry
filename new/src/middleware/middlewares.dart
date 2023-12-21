import 'middleware.dart';

class Middlewares {
  /// Internal storage.
  final _storage = <Middleware>[];

  /// Adds a pre-initialized [Middleware] instance.
  ///
  /// If [prepend] is `true`, the [middleware] will be added to the beginning
  /// of the middleware stack.
  void use(Middleware middleware, {bool prepend = false}) {
    return switch (prepend) {
      true => _storage.insert(0, middleware),
      _ => _storage.add(middleware),
    };
  }

  /// Resolves the configured middleware for a given middleware stack.
  Iterable<Middleware> resolve() => _storage;
}
