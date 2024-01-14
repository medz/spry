// ignore_for_file: file_names

extension MapValueOf<K, V> on Map<K, V> {
  T valueOf<T>(K key, T Function(V? value) factory) {
    return switch (this[key]) {
      T value => value,
      V? value => factory(value),
    };
  }
}
