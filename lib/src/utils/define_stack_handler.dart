import '../composable/next.dart';
import '../handler.dart';
import '../event.dart';
import 'define_handler.dart';

Handler defineStackHandler(Iterable<Handler> handlers) {
  final handle = handlers.reversed.fold<Future<void> Function(Event)>(
    (_) async {},
    (child, handler) => (event) async {
      setNext(() => child(event));

      return handler.handle(event);
    },
  );

  return defineHandler(handle);
}

extension<T> on Iterable<T> {
  Iterable<T> get reversed {
    return switch (this) {
      List<T>(reversed: final reversed) => reversed,
      _ => toList().reversed,
    };
  }
}
