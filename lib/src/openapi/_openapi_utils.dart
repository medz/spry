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

/// Reads a required string field from a JSON map.
///
/// Throws [FormatException] when the key is absent or its value is not a String.
/// Use [scope] to identify the containing object in the error message.
String requireString(
  Map<String, Object?> json,
  String key, {
  required String scope,
}) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Invalid $scope.$key: expected a string.');
}

/// Casts [value] to a required `Map<String, Object?>`.
///
/// Throws [FormatException] when the value is not a JSON object.
/// Use [scope] to identify the containing object in the error message.
Map<String, Object?> requireMap(Object? value, {required String scope}) {
  if (value is Map<String, Object?>) return value;
  throw FormatException('Invalid $scope: expected a JSON object.');
}

/// Casts [value] to an optional `Map<String, Object?>`.
///
/// Returns `null` when [value] is `null`.
/// Throws [FormatException] when [value] is present but not a JSON object.
/// Use [scope] to identify the containing object in the error message.
Map<String, Object?>? optionalMap(Object? value, {required String scope}) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  throw FormatException('Invalid $scope: expected a JSON object.');
}

/// Casts [value] to a required `List<Object?>`.
///
/// Throws [FormatException] when the value is not a JSON array.
/// Use [scope] to identify the containing object in the error message.
List<Object?> requireList(Object? value, {required String scope}) {
  if (value is List) return value.cast<Object?>();
  throw FormatException('Invalid $scope: expected a JSON array.');
}

/// Validates that exactly one of [schema] or [content] is provided.
///
/// Throws [ArgumentError] when both are null, both are non-null, or when
/// [content] is provided with a number of entries other than exactly one.
/// Use [scope] to identify the containing object in error messages.
void validateSchemaOrContent({
  required Object? schema,
  required Map<String, Object?>? content,
  required String scope,
}) {
  if (schema == null && content == null) {
    throw ArgumentError('$scope requires `schema` or `content`.');
  }
  if (schema != null && content != null) {
    throw ArgumentError('$scope cannot have both `schema` and `content`.');
  }
  if (content != null && content.length != 1) {
    throw ArgumentError(
      '$scope.content must contain exactly one media type entry.',
    );
  }
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
