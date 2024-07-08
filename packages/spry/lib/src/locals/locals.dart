abstract final class Locals {
  T get<T>(Object key);
  void set<T>(Object key, T value);
  void remove(Object key);
}

final class AppLocals implements Locals {
  final Map locals = {};

  @override
  T get<T>(Object key) => locals[key];

  @override
  void set<T>(Object key, T value) {
    locals[key] = value;
  }

  @override
  void remove(Object key) {
    locals.remove(key);
  }
}

final class EventLocals implements Locals {
  EventLocals(this.appLocals);

  final Locals appLocals;
  final Map locals = {};

  @override
  T get<T>(Object key) {
    return switch (locals[key]) {
      null => appLocals.get<T>(key),
      Object value => value as T,
    };
  }

  @override
  void remove(Object key) {
    locals.remove(key);
  }

  @override
  void set<T>(Object key, T value) {
    locals[key] = value;
  }
}
