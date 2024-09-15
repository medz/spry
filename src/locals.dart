/// Spry app locals.
extension type Locals._(Map _) implements Map {
  /// Returns a nullable value of [key], value typed for [T].
  T? maybeOf<T>(Object? key) {
    return switch (_[key]) {
      T value => value,
      _ => null,
    };
  }

  /// Returns a [T] typed value of [key]
  T of<T>(Object key) {
    return switch (maybeOf<T>(key)) {
      T value => value,
      _ => throw Error(), // TODO
    };
  }
}
