// ignore_for_file: file_names

import '../_internal/map+value_of.dart';
import '../application.dart';
import 'middleware_stack.dart';

extension Application$Middleware on Application {
  static const _key = #spry.middleware.stack;

  /// Returns current application global middleware stack.
  MiddlewareStack get middleware {
    return locals.valueOf(_key, (_) {
      final stack = MiddlewareStack(this);
      logger.config('Created middleware stack');

      return locals[_key] = stack;
    });
  }
}
