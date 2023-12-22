import '../spry.dart';
import 'middleware_stack.dart';

extension SpryMiddlewareProps on Spry {
  /// Returns the configured middleware stack.
  MiddlewareStack get middleware {
    final existing = container.get<MiddlewareStack>();
    if (existing != null) return existing;

    final stack = MiddlewareStack();
    container.set(stack);

    return stack;
  }
}
