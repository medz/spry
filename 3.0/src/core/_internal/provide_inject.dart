abstract mixin class ProvideInject {
  final Map<dynamic, dynamic Function()> _factories = {};
  final Map _values = {};

  /// Provide a value or a factory function.
  void provide<K, T>(K token, T Function() factory) {
    _factories.remove(token);
    _values.remove(token);

    _factories[token] = factory;
  }

  /// Returns a value for a token.
  ///
  /// If the token is not provided, it will throw an error.
  T inject<K, T>(K token, [T Function()? orElse]) {
    if (_values.containsKey(token)) {
      return _values[token];
    } else if (_factories.containsKey(token)) {
      return _values[token] = _factories[token]?.call();
    } else if (orElse != null) {
      return orElse();
    }

    throw ArgumentError.value(token, 'token', 'is not provided');
  }
}
