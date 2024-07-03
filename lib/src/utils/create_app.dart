import '../_core_keys.dart';
import '../app.dart';
import '../composable/next.dart';
import '../context.dart';
import '../define_handler.dart';
import '../event.dart';
import '../handler.dart';

App createApp() {
  final app = _AppImpl();

  app.context = _AppContext();
  app.context.set(kAppInstance, app);

  return app;
}

final class _AppImpl implements App {
  final handlerStack = <Handler>[];

  @override
  void use(Handler handler) {
    handlerStack.add(handler);
  }

  @override
  Handler get handler => _createStackHandler(handlerStack.reversed);

  @override
  late final Context context;
}

final class _AppContext implements Context {
  final Map locals = {};

  @override
  T? getOrNull<T>(Object key) {
    return switch (locals[key]) {
      T value => value,
      _ => null,
    };
  }

  @override
  T get<T>(Object key) {
    return switch (getOrNull(key)) {
      T value => value,
      _ => throw 111,
    };
  }

  @override
  bool has(Object key) => locals.containsKey(key);

  @override
  T set<T>(Object key, T value) => locals[key] = value;

  @override
  T upsert<T>(Object key, T Function() create) {
    return switch (locals[key]) {
      T value => value,
      _ => set(key, create()),
    };
  }
}

Handler _createStackHandler(Iterable<Handler> stack) {
  final handle = stack.fold<Future<void> Function(Event)>(
    (_) async {},
    (child, handler) => (event) async {
      setNext(() => child(event));

      return handler.handle(event);
    },
  );

  return defineHandler(handle);
}
