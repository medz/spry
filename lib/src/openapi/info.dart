import '_openapi_utils.dart';

/// OpenAPI `info` object used by config and document models.
extension type OpenAPIInfo._(Map<String, Object?> _) {
  /// Creates an OpenAPI info object.
  factory OpenAPIInfo({
    required String title,
    required String version,
    String? summary,
    String? description,
    String? termsOfService,
    OpenAPIContact? contact,
    OpenAPILicense? license,
    Map<String, Object?>? extensions,
  }) => OpenAPIInfo._({
    'title': title,
    'version': version,
    'summary': ?summary,
    'description': ?description,
    'termsOfService': ?termsOfService,
    'contact': ?contact,
    'license': ?license,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIInfo.fromJson(Map<String, Object?> json) => OpenAPIInfo._({
    'title': requireString(json, 'title', scope: 'openapi'),
    'version': requireString(json, 'version', scope: 'openapi'),
    'summary': ?optionalString(json, 'summary', scope: 'openapi'),
    'description': ?optionalString(json, 'description', scope: 'openapi'),
    'termsOfService': ?optionalString(json, 'termsOfService', scope: 'openapi'),
    'contact': ?switch (optionalMap(json['contact'], scope: 'openapi')) {
      final value? => OpenAPIContact.fromJson(value),
      null => null,
    },
    'license': ?switch (optionalMap(json['license'], scope: 'openapi')) {
      final value? => OpenAPILicense.fromJson(value),
      null => null,
    },
    ...extractExtensions(json),
  });

  /// API title.
  String get title => _['title'] as String;

  /// API version.
  String get version => _['version'] as String;

  /// Optional summary.
  String? get summary => _['summary'] as String?;

  /// Optional description.
  String? get description => _['description'] as String?;

  /// Optional terms of service URL.
  String? get termsOfService => _['termsOfService'] as String?;

  /// Optional contact.
  OpenAPIContact? get contact => _['contact'] as OpenAPIContact?;

  /// Optional license.
  OpenAPILicense? get license => _['license'] as OpenAPILicense?;
}

/// OpenAPI `contact` object.
extension type OpenAPIContact._(Map<String, Object?> _) {
  /// Creates an OpenAPI contact object.
  factory OpenAPIContact({
    String? name,
    String? url,
    String? email,
    Map<String, Object?>? extensions,
  }) => OpenAPIContact._({
    'name': ?name,
    'url': ?url,
    'email': ?email,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIContact.fromJson(Map<String, Object?> json) =>
      OpenAPIContact._({
        'name': ?optionalString(json, 'name', scope: 'openapi'),
        'url': ?optionalString(json, 'url', scope: 'openapi'),
        'email': ?optionalString(json, 'email', scope: 'openapi'),
        ...extractExtensions(json),
      });
}

/// OpenAPI `license` object.
extension type OpenAPILicense._(Map<String, Object?> _) {
  /// Creates an OpenAPI license object.
  factory OpenAPILicense({
    required String name,
    String? identifier,
    String? url,
    Map<String, Object?>? extensions,
  }) {
    _validateExclusiveFields(
      identifier: identifier,
      url: url,
      scope: 'OpenAPILicense',
    );
    return OpenAPILicense._({
      'name': name,
      'identifier': ?identifier,
      'url': ?url,
      ...?prefixExtensions(extensions),
    });
  }

  /// Wraps decoded JSON.
  factory OpenAPILicense.fromJson(Map<String, Object?> json) {
    final identifier = optionalString(json, 'identifier', scope: 'openapi');
    final url = optionalString(json, 'url', scope: 'openapi');
    _validateExclusiveFields(
      identifier: identifier,
      url: url,
      scope: 'OpenAPILicense',
    );
    return OpenAPILicense._({
      'name': requireString(json, 'name', scope: 'openapi'),
      'identifier': ?identifier,
      'url': ?url,
      ...extractExtensions(json),
    });
  }
}

void _validateExclusiveFields({
  String? identifier,
  String? url,
  required String scope,
}) {
  if (identifier != null && url != null) {
    throw ArgumentError(
      '$scope.identifier and $scope.url are mutually exclusive.',
    );
  }
}

