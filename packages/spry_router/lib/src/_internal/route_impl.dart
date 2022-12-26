import 'dart:async';

import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

import '../route.dart';

class RouteImpl extends Route {
  @override
  final String path;

  @override
  final Prexp prexp;

  @override
  final String verb;

  /// The roite handler.
  final Handler handler;

  /// The route middleware.
  Middleware? middleware;

  /// constructor.
  RouteImpl(this.verb, this.path, this.handler)
      : prexp = Prexp.fromString(path);

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  FutureOr<void> call(Context context) async {
    /// The route middleware.
    final Middleware middleware = this.middleware ?? _defaultMiddleware;

    // Define the middleware next function.
    next() => handler(context);

    // Call middleware create a handler.
    await middleware(context, next);
  }

  /// Default empty middleware.
  static FutureOr<void> _defaultMiddleware(
          Context context, MiddlewareNext next) =>
      next();
}
