import 'dart:core' as core;

/// Mutable request-local storage keyed by symbols.
extension type Locals(core.Map<core.Symbol, core.Object?> _values)
    implements core.Map<core.Symbol, core.Object?> {
  /// Returns the typed value for [key], or `null` when absent.
  T? get<T>(core.Symbol key) => _values[key] as T?;

  /// Stores [value] under [key].
  void set(core.Symbol key, core.Object? value) {
    _values[key] = value;
  }

  /// Returns whether [key] is present.
  core.bool has(core.Symbol key) => _values.containsKey(key);
}
