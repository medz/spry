import '../_core_keys.dart';
import '../app.dart';
import '../context.dart';
import '../handler.dart';
import 'define_stack_handler.dart';

App createApp({Map? locals}) {
  final context = _AppContext();
  if (locals != null && locals.isNotEmpty) {
    for (final e in locals.entries) {
      context.set(e.key, e.value);
    }
  }

  final app = _AppImpl(context);
  context.set(kAppInstance, app);

  return app;
}

final class _AppImpl implements App {
  _AppImpl(this.context);

  final handlerStack = <Handler>[];

  @override
  final Context context;

  @override
  Handler get handler => defineStackHandler(handlerStack);

  @override
  void use(Handler handler) {
    handlerStack.add(handler);
  }
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
