import 'dart:core' as core;

extension type RouteParams(core.Map<core.String, core.String> _values)
    implements core.Map<core.String, core.String> {
  core.String? get(core.String name) => _values[name];

  core.String required(core.String name) {
    return _values[name] ??
        (throw core.StateError('Missing route param: "$name"'));
  }

  core.int int(core.String name) => core.int.parse(required(name));

  core.num num(core.String name) => core.num.parse(required(name));

  core.double double(core.String name) => core.double.parse(required(name));

  T decode<T>(core.String name, T Function(core.String value) decoder) {
    return decoder(required(name));
  }

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

  core.String? get wildcard => _values['wildcard'];
}
