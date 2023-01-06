import 'dart:async';

import 'package:spry/spry.dart';

/// Param Middleware next function.
typedef ParamNext = FutureOr<void> Function(Object? value);

/// Param middleware.
typedef ParamMiddleware = FutureOr<void> Function(
    Context context, Object? value, ParamNext next);

extension MiddlewareExtension on ParamMiddleware {
  /// Wraps this [Middleware] with [other].
  ///
  /// Example:
  /// ```dart
  /// middleware1.use(middleware2);
  /// ```
  ParamMiddleware use(ParamMiddleware other) {
    return (context, value, next) {
      return this(context, value, (value) => other(context, value, next));
    };
  }
}
