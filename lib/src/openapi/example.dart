/// OpenAPI `example` object.
extension type OpenAPIExample._(Map<String, Object?> _) {
  /// Creates an example object.
  factory OpenAPIExample({
    String? summary,
    String? description,
    Object? value,
    String? externalValue,
    Map<String, dynamic>? extensions,
  }) {
    _validateExampleValueFields(
      value: value,
      externalValue: externalValue,
      scope: 'OpenAPIExample',
    );
    return OpenAPIExample._({
      'summary': ?summary,
      'description': ?description,
      'value': ?value,
      'externalValue': ?externalValue,
      ...?_prefixExtensions(extensions),
    });
  }
}

void _validateExampleValueFields({
  required Object? value,
  required String? externalValue,
  required String scope,
}) {
  if (value != null && externalValue != null) {
    throw ArgumentError(
      '$scope.value and $scope.externalValue are mutually exclusive.',
    );
  }
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}
