import 'middleware.dart';

class MiddlewareStack extends Iterable<Middleware> {
  /// Internal middleware stack.
  final _stack = <Middleware>[];

  /// Adds a pre-initialized [Middleware] instance.
  ///
  /// If [prepend] is `true`, the [middleware] will be added to the beginning
  /// of the middleware stack.
  void use(Middleware middleware, {bool prepend = false}) {
    if (prepend) {
      return _stack.insert(0, middleware);
    }

    _stack.add(middleware);
  }

  /// Clears the middleware stack.
  void clear() => _stack.clear();

  @override
  Iterator<Middleware> get iterator => _stack.iterator;
}
