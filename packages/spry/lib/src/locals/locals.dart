/// [Spry]/[Event] locals.
abstract interface class Locals {
  /// Gets a type of [T] value for [key].
  T get<T>(Object key);

  /// Sets a type of [T] value.
  void set<T>(Object key, T value);

  /// Remove a value for [key].
  void remove(Object key);
}
