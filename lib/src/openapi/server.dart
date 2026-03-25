import '_openapi_utils.dart';

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
    'description': ?description,
    'variables': ?variables,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIServer.fromJson(Map<String, dynamic> json) => OpenAPIServer._({
    'url': _requireString(json, 'url'),
    'description': ?_string(json['description']),
    if (json['variables'] case final Map<String, dynamic> value)
      'variables': {
        for (final entry in value.entries)
          entry.key: OpenAPIServerVariable.fromJson(_requireMap(entry.value)),
      },
    ...extractExtensions(json),
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
    'enum': ?values,
    'description': ?description,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIServerVariable.fromJson(Map<String, dynamic> json) =>
      OpenAPIServerVariable._({
        'default': _requireString(json, 'default'),
        'enum': ?_stringList(json['enum']),
        'description': ?_string(json['description']),
        ...extractExtensions(json),
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
