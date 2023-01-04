import '../context.dart';
import '../middleware.dart';

extension MiddlewareExtension on Middleware {
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
