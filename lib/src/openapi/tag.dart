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
        'url': requireString(json, 'url', scope: 'openapi tag'),
        'description': ?optionalString(json, 'description', scope: 'openapi tag'),
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
    'name': requireString(json, 'name', scope: 'openapi tag'),
    'description': ?optionalString(json, 'description', scope: 'openapi tag'),
    'externalDocs': ?switch (optionalMap(json['externalDocs'], scope: 'openapi tag')) {
      final value? => OpenAPIExternalDocs.fromJson(value),
      null => null,
    },
    ...extractExtensions(json),
  });
}


