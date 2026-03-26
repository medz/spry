import '_openapi_utils.dart';

/// OpenAPI `external-documentation` object.
extension type OpenAPIExternalDocs._(Map<String, Object?> _) {
  /// Creates an external docs object.
  factory OpenAPIExternalDocs({
    required String url,
    String? description,
    Map<String, Object?>? extensions,
  }) => OpenAPIExternalDocs._({
    'url': url,
    'description': ?description,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIExternalDocs.fromJson(Map<String, Object?> json) =>
      OpenAPIExternalDocs._({
        'url': _requireString(json, 'url'),
        'description': ?_string(json['description']),
        ...extractExtensions(json),
      });
}

/// OpenAPI `tag` object.
extension type OpenAPITag._(Map<String, Object?> _) {
  /// Creates a tag object.
  factory OpenAPITag({
    required String name,
    String? description,
    OpenAPIExternalDocs? externalDocs,
    Map<String, Object?>? extensions,
  }) => OpenAPITag._({
    'name': name,
    'description': ?description,
    'externalDocs': ?externalDocs,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPITag.fromJson(Map<String, Object?> json) => OpenAPITag._({
    'name': _requireString(json, 'name'),
    'description': ?_string(json['description']),
    'externalDocs': ?switch (_map(json['externalDocs'])) {
      final value? => OpenAPIExternalDocs.fromJson(value),
      null => null,
    },
    ...extractExtensions(json),
  });
}

Map<String, Object?>? _map(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Invalid openapi tag value: expected a JSON object.');
}

String _requireString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Invalid openapi tag.$key: expected a string.');
}

String? _string(Object? value) => value is String ? value : null;
