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
    'url': requireString(json, 'url', scope: 'openapi.server'),
    'description': ?optionalString(
      json,
      'description',
      scope: 'openapi.server',
    ),
    if (json.containsKey('variables'))
      'variables': {
        for (final entry in requireMap(
          json['variables'],
          scope: 'openapi.server',
        ).entries)
          entry.key: OpenAPIServerVariable.fromJson(
            requireMap(entry.value, scope: 'openapi.server.variables'),
          ),
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
        'default': requireString(
          json,
          'default',
          scope: 'openapi.serverVariable',
        ),
        'enum': ?_stringList(json['enum']),
        'description': ?optionalString(
          json,
          'description',
          scope: 'openapi.serverVariable',
        ),
        ...extractExtensions(json),
      });
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
