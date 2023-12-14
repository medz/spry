/// Provide a value or a factory function and returns a value for a token.
abstract mixin class ProvideInject {
  final Map<dynamic, dynamic Function()> _factories = {};
  final Map _values = {};

  /// Contains a token exists.
  bool contains<K>(K token) {
    return _factories.containsKey(token) || _values.containsKey(token);
  }

  /// Provide a value or a factory function.
  void provide<K, T>(K token, T Function() factory) {
    _factories.remove(token);
    _values.remove(token);

    _factories[token] = factory;
  }

  /// Returns a value for a token.
  ///
  /// - If the token is not provided, it will throw an error.
  ///
  /// ## Parameters
  /// - [token]: The token to inject.
  /// - [orElse]: A function to call if the token is not provided.
  T inject<K, T>(K token, [T Function()? orElse]) {
    // If value is provided, return it.
    if (_values.containsKey(token)) return _values[token];

    // If factory is provided, call it and return the value.
    if (_factories.containsKey(token)) {
      return _values[token] = _factories[token]?.call();
    }

    // If orElse is provided, call it and return the value.
    if (orElse != null) return orElse();

    // If nothing is provided, throw an error.
    throw ArgumentError.value(token, 'token', 'is not provided');
  }
}
