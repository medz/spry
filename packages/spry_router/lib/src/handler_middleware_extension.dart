import 'dart:async';

import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

import '_internal/constants.dart';
import '_internal/empty_functions.dart';
import 'param_middleware.dart';

/// Handler Middleware extension.
extension HandlerMiddlewareExtension on Handler {
  /// Use a middleware.
  Handler use(Middleware middleware) {
    if (this is _MiddlewareHandler) {
      return (this as _MiddlewareHandler).use(middleware);
    }

    return _MiddlewareHandler(this, middleware);
  }

  /// Use a param middleware.
  Handler param(String name, ParamMiddleware middleware) {
    if (this is _MiddlewareHandler) {
      return (this as _MiddlewareHandler).param(name, middleware);
    }

    return _MiddlewareHandler(this, emptyMiddleware).param(name, middleware);
  }
}

/// Middleware handler.
class _MiddlewareHandler {
  /// The handler.
  final Handler handler;

  /// Param middleware.
  final Map<String, ParamMiddleware> paramMiddleware = {};

  /// The middleware.
  Middleware middleware;

  /// Constructor.
  _MiddlewareHandler(this.handler, this.middleware);

  // Call the handler.
  FutureOr<void> call(Context context) async {
    final Map<String, Object?> params =
        context.get(SPRY_REQUEST_PARAMS) as Map<String, Object?>? ?? {};
    for (final String name in params.keys) {
      final ParamMiddleware? middleware = paramMiddleware[name];
      if (middleware != null) {
        next(Object? value) => params[name] = value;

        // Call middleware
        await middleware(context, params[name], next);
      }
    }

    /// The route middleware. call
    return middleware(context, () => handler(context));
  }

  /// Use a middleware.
  Handler use(Middleware middleware) {
    this.middleware = this.middleware.use(middleware);

    return this;
  }

  /// Use a param middleware
  Handler param(String name, ParamMiddleware middleware) {
    paramMiddleware[name] =
        paramMiddleware[name]?.use(middleware) ?? middleware;

    return this;
  }
}
