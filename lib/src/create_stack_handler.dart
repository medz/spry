import 'composable/next.dart';
import 'define_handler.dart';
import 'event.dart';
import 'handler.dart';

Handler createStackHandler(Iterable<Handler> stack) {
  final handle = stack.fold<Future<void> Function(Event)>(
    (_) async {},
    (child, handler) => (event) async {
      setNext(() => child(event));

      return handler.handle(event);
    },
  );

  return defineHandler(handle);
}
