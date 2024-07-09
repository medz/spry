abstract interface class Locals {
  T get<T>(Object key);
  void set<T>(Object key, T value);
  void remove(Object key);
}
