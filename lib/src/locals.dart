import 'dart:core' as core;

extension type Locals(core.Map<core.Symbol, core.Object?> _values)
    implements core.Map<core.Symbol, core.Object?> {
  T? get<T>(core.Symbol key) => _values[key] as T?;

  void set(core.Symbol key, core.Object? value) {
    _values[key] = value;
  }

  core.bool has(core.Symbol key) => _values.containsKey(key);
}
