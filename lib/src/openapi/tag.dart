/// OpenAPI `external-documentation` object.
extension type OpenAPIExternalDocs._(Map<String, Object?> _) {
  /// Creates an external docs object.
  factory OpenAPIExternalDocs({
    required String url,
    String? description,
    Map<String, dynamic>? extensions,
  }) => OpenAPIExternalDocs._({
    'url': url,
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIExternalDocs.fromJson(Map<String, dynamic> json) =>
      OpenAPIExternalDocs._({
        'url': _requireString(json, 'url'),
        ...?switch (_string(json['description'])) {
          final value? => {'description': value},
          null => null,
        },
        ..._extractExtensions(json),
      });
}

/// OpenAPI `tag` object.
extension type OpenAPITag._(Map<String, Object?> _) {
  /// Creates a tag object.
  factory OpenAPITag({
    required String name,
    String? description,
    OpenAPIExternalDocs? externalDocs,
    Map<String, dynamic>? extensions,
  }) => OpenAPITag._({
    'name': name,
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (externalDocs) {
      final value? => {'externalDocs': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPITag.fromJson(Map<String, dynamic> json) => OpenAPITag._({
    'name': _requireString(json, 'name'),
    ...?switch (_string(json['description'])) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (_map(json['externalDocs'])) {
      final value? => {'externalDocs': OpenAPIExternalDocs.fromJson(value)},
      null => null,
    },
    ..._extractExtensions(json),
  });
}

Map<String, dynamic>? _map(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Invalid openapi tag value: expected a JSON object.');
}

Map<String, Object?> _extractExtensions(Map<String, dynamic> json) {
  return {
    for (final entry in json.entries)
      if (entry.key.startsWith('x-')) entry.key: entry.value,
  };
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Invalid openapi tag.$key: expected a string.');
}

String? _string(Object? value) => value is String ? value : null;
