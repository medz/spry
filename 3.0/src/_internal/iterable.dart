extension InternalIterable<T> on Iterable<T> {
  /// First where, or null if none.
  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}
