import '../application.dart';
import 'middleware.dart';

class MiddlewareStack extends Iterable<Middleware> {
  final Application _application;

  MiddlewareStack(Application application) : _application = application;

  /// Internal middleware stack.
  final _stack = <Middleware>[];

  @override
  Iterator<Middleware> get iterator => _stack.iterator;

  /// Adds a [Middleware] to the stack.
  ///
  /// If [prepend] is `true`, the [middleware] will be added to the beginning of
  /// the stack.
  void addMiddleware(Middleware middleware, {prepend = false}) {
    if (prepend) {
      _application.logger.config('Prepending middleware: $middleware');

      return _stack.insert(0, middleware);
    }

    _application.logger.config('Appending middleware: $middleware');
    _stack.add(middleware);
  }
}
