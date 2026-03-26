// Internal utilities shared across OpenAPI extension-type objects.
// Functions use non-underscore names so they are importable within
// lib/src/openapi/. They are not exported from any public API surface.

/// Adds the `x-` prefix to each extension key.
///
/// If a key already starts with `x-` it is left unchanged to prevent
/// double-prefixing (e.g. passing `'x-foo'` would otherwise become `'x-x-foo'`).
Map<String, Object?>? prefixExtensions(Map<String, Object?>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries)
      '${entry.key.startsWith('x-') ? '' : 'x-'}${entry.key}': entry.value,
  };
}

/// Extracts all `x-` vendor extension entries from a JSON object.
Map<String, Object?> extractExtensions(Map<String, Object?> json) {
  return {
    for (final entry in json.entries)
      if (entry.key.startsWith('x-')) entry.key: entry.value,
  };
}

/// Reads an optional string field from a JSON map.
///
/// Returns `null` when the key is absent or its value is `null`.
/// Throws [FormatException] when the key is present with a non-String value.
/// Use [scope] to identify the containing object in the error message.
String? optionalString(
  Map<String, Object?> json,
  String key, {
  required String scope,
}) {
  if (!json.containsKey(key)) return null;
  final value = json[key];
  if (value == null || value is String) return value as String?;
  throw FormatException(
    'Invalid $scope.$key: expected a string, got ${value.runtimeType}.',
  );
}

/// Validates that [example] and [examples] are not both set.
///
/// Throws [ArgumentError] if both are non-null, using [scope] to identify
/// the containing object in the error message.
void validateExampleMutualExclusivity({
  required Object? example,
  required Object? examples,
  required String scope,
}) {
  if (example != null && examples != null) {
    throw ArgumentError(
      '$scope.example and $scope.examples are mutually exclusive.',
    );
  }
}
