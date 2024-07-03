import '../app.dart';
import '../context.dart';

Context createEventContext(App app, [Map? locals]) {
  final context = _RequestEventContext(app);

  if (locals != null && locals.isNotEmpty) {
    for (final e in locals.entries) {
      context.set(e.key, e.value);
    }
  }

  return context;
}

class _RequestEventContext implements Context {
  _RequestEventContext(this.app);

  final App app;
  final Map locals = {};

  @override
  T? getOrNull<T>(Object key) {
    return switch (locals[key]) {
      T value => value,
      _ => app.context.getOrNull(key),
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
  bool has(Object key) {
    return switch (locals.containsKey(key)) {
      false => app.context.has(key),
      _ => true,
    };
  }

  @override
  T set<T>(Object key, T value) => locals[key] = value;

  @override
  T upsert<T>(Object key, T Function() create) {
    return switch (has(key)) {
      true => get(key),
      _ => set(key, create()),
    };
  }
}
