import '_openapi_utils.dart';

/// OpenAPI `server` object.
extension type OpenAPIServer._(Map<String, Object?> _) {
  /// Creates a server object.
  factory OpenAPIServer({
    required String url,
    String? description,
    Map<String, OpenAPIServerVariable>? variables,
    Map<String, Object?>? extensions,
  }) => OpenAPIServer._({
    'url': url,
    'description': ?description,
    'variables': ?variables,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIServer.fromJson(Map<String, Object?> json) => OpenAPIServer._({
    'url': _requireString(json, 'url'),
    'description': ?_string(json['description']),
    if (json.containsKey('variables'))
      'variables': {
        for (final entry in _requireMap(json['variables']).entries)
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
    Map<String, Object?>? extensions,
  }) => OpenAPIServerVariable._({
    'default': defaultValue,
    'enum': ?values,
    'description': ?description,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIServerVariable.fromJson(Map<String, Object?> json) =>
      OpenAPIServerVariable._({
        'default': _requireString(json, 'default'),
        'enum': ?_stringList(json['enum']),
        'description': ?_string(json['description']),
        ...extractExtensions(json),
      });
}

Map<String, Object?> _requireMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException(
    'Invalid openapi.server value: expected a JSON object.',
  );
}

String _requireString(Map<String, Object?> json, String key) {
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
  if (value is! List) {
    throw FormatException(
      'Invalid openapi.server enum: expected a string array.',
    );
  }
  final result = <String>[];
  for (final item in value) {
    if (item is! String) {
      throw FormatException(
        'Invalid openapi.server enum entry: expected a string, got ${item.runtimeType}.',
      );
    }
    result.add(item);
  }
  return result;
}

String? _string(Object? value) => value is String ? value : null;
