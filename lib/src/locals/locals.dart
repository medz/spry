abstract final class Locals {
  T get<T>(Object key);
  void set<T>(Object key, T value);
  void remove(Object key);
}

final class LocalsImpl implements Locals {
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
