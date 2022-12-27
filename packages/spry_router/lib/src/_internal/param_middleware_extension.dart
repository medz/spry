import 'package:spry/spry.dart';

import '../param_middleware.dart';

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
