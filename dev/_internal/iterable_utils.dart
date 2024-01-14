extension IterableUtils<T> on Iterable<T> {
  /// Returns first where or null.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
