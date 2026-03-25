/// OpenAPI `server` object.
extension type OpenAPIServer._(Map<String, Object?> _) {
  /// Creates a server object.
  factory OpenAPIServer({
    required String url,
    String? description,
    Map<String, OpenAPIServerVariable>? variables,
    Map<String, dynamic>? extensions,
  }) => OpenAPIServer._({
    'url': url,
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (variables) {
      final value? => {'variables': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIServer.fromJson(Map<String, dynamic> json) => OpenAPIServer._({
    'url': _requireString(json, 'url'),
    ...?switch (_string(json['description'])) {
      final value? => {'description': value},
      null => null,
    },
    if (json['variables'] case final Map<String, dynamic> value)
      'variables': {
        for (final entry in value.entries)
          entry.key: OpenAPIServerVariable.fromJson(_requireMap(entry.value)),
      },
    ..._extractExtensions(json),
  });
}

/// OpenAPI `server-variable` object.
extension type OpenAPIServerVariable._(Map<String, Object?> _) {
  /// Creates a server variable object.
  factory OpenAPIServerVariable({
    required String defaultValue,
    List<String>? values,
    String? description,
    Map<String, dynamic>? extensions,
  }) => OpenAPIServerVariable._({
    'default': defaultValue,
    ...?switch (values) {
      final value? => {'enum': value},
      null => null,
    },
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIServerVariable.fromJson(Map<String, dynamic> json) =>
      OpenAPIServerVariable._({
        'default': _requireString(json, 'default'),
        ...?switch (_stringList(json['enum'])) {
          final value? => {'enum': value},
          null => null,
        },
        ...?switch (_string(json['description'])) {
          final value? => {'description': value},
          null => null,
        },
        ..._extractExtensions(json),
      });
}

Map<String, dynamic> _requireMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException(
    'Invalid openapi.server value: expected a JSON object.',
  );
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
  throw FormatException('Invalid openapi.server.$key: expected a string.');
}

List<String>? _stringList(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    return value.cast<String>();
  }
  throw FormatException(
    'Invalid openapi.server enum: expected a string array.',
  );
}

String? _string(Object? value) => value is String ? value : null;
