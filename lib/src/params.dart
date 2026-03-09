import 'dart:core' as core;

/// Route parameters exposed as typed helpers.
extension type RouteParams(core.Map<core.String, core.String> _values)
    implements core.Map<core.String, core.String> {
  /// Returns the raw value for [name], or `null` when absent.
  core.String? get(core.String name) => _values[name];

  /// Returns the raw value for [name], or throws when absent.
  core.String required(core.String name) {
    return _values[name] ??
        (throw core.StateError('Missing route param: "$name"'));
  }

  /// Parses [name] as an integer.
  core.int int(core.String name) => core.int.parse(required(name));

  /// Parses [name] as a number.
  core.num num(core.String name) => core.num.parse(required(name));

  /// Parses [name] as a double.
  core.double double(core.String name) => core.double.parse(required(name));

  /// Decodes [name] with a custom decoder.
  T decode<T>(core.String name, T Function(core.String value) decoder) {
    return decoder(required(name));
  }

  /// Parses [name] as an enum entry from [values].
  T $enum<T extends core.Enum>(core.String name, core.List<T> values) {
    return decode(
      name,
      (value) => values.firstWhere(
        (entry) => entry.name == value,
        orElse: () => throw core.StateError(
          'Invalid value "$value" for param "$name". '
          'Expected: ${values.map((entry) => entry.name).join(', ')}',
        ),
      ),
    );
  }

  /// Returns the wildcard route parameter when present.
  core.String? get wildcard => _values['wildcard'];
}
