import 'package:routingkit/routingkit.dart';

import '../types.dart';

abstract class RoutesBuilder {
  const RoutesBuilder();

  /// Middleware router context.
  RouterContext<Middleware> get middleware;

  /// Request handler route context.
  RouterContext<Handler> get router;

  /// Register a middleware.
  void use(Middleware fn, {String? method, String path = '/'}) {
    addRoute(middleware, method, path, fn);
  }

  /// Listen a request.
  void on<T>(Handler<T> handler, {String? method, String path = '/'}) {
    addRoute(router, method, path, handler);
  }
}
