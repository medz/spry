abstract interface class Context {
  T get<T>(Object key);
  T? getOrNull<T>(Object key);
  T set<T>(Object key, T value);
  T upsert<T>(Object key, T Function() create);
  bool has(Object key);
}
