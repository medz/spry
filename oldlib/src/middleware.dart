import 'dart:async';

import 'context.dart';
import 'handler.dart';

/// Middleware next function type.
typedef Next = FutureOr<void> Function();

/// A function which creates a new [Handler] by wrapping a [Handler].
///
/// This is used to create a new [Handler] by wrapping an existing [Handler].
typedef Middleware = FutureOr<void> Function(Context context, Next next);

/// Middleware Chain.
extension MiddlewareChain on Middleware {
  /// Wraps this [Middleware] with [other].
  ///
  /// Example:
  /// ```dart
  /// middleware1.use(middleware2);
  /// ```
  Middleware use(Middleware other) {
    return (Context context, Next next) {
      return this(context, () => other(context, next));
    };
  }
}

/// Empty middleware.
///
/// The empty middleware does nothing. this is used as a default value for [Spry.middleware] or as a base for [Middleware.use].
FutureOr<void> emptyMiddleware(Context context, Next next) => next();
