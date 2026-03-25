// Internal utilities shared across OpenAPI extension-type objects.
// Functions use non-underscore names so they are importable within
// lib/src/openapi/. They are not exported from any public API surface.

/// Adds the `x-` prefix to each extension key.
///
/// If a key already starts with `x-` it is left unchanged to prevent
/// double-prefixing (e.g. passing `'x-foo'` would otherwise become `'x-x-foo'`).
Map<String, Object?>? prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries)
      '${entry.key.startsWith('x-') ? '' : 'x-'}${entry.key}': entry.value,
  };
}

/// Extracts all `x-` vendor extension entries from a JSON object.
Map<String, Object?> extractExtensions(Map<String, dynamic> json) {
  return {
    for (final entry in json.entries)
      if (entry.key.startsWith('x-')) entry.key: entry.value,
  };
}
