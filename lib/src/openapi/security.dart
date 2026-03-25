import '_openapi_utils.dart';
import 'oauth.dart';

/// OpenAPI security requirement object.
extension type OpenAPISecurityRequirement._(Map<String, Object?> _) {
  /// Creates a security requirement object.
  factory OpenAPISecurityRequirement(Map<String, List<String>> schemes) =>
      OpenAPISecurityRequirement._({
        for (final entry in schemes.entries) entry.key: entry.value,
      });
}

/// Supported locations for `apiKey` schemes.
enum OpenAPIApiKeyLocation {
  /// API key is sent in the query string.
  query,

  /// API key is sent in a header.
  header,

  /// API key is sent in a cookie.
  cookie,
}

/// OpenAPI security scheme object.
extension type OpenAPISecurityScheme._(Map<String, Object?> _) {
  /// Creates an `apiKey` security scheme.
  factory OpenAPISecurityScheme.apiKey({
    required String name,
    required OpenAPIApiKeyLocation location,
    String? description,
    Map<String, dynamic>? extensions,
  }) => OpenAPISecurityScheme._({
    'type': 'apiKey',
    'name': name,
    'in': location.name,
    'description': ?description,
    ...?prefixExtensions(extensions),
  });

  /// Creates an `http` security scheme.
  factory OpenAPISecurityScheme.http({
    required String scheme,
    String? bearerFormat,
    String? description,
    Map<String, dynamic>? extensions,
  }) {
    if (bearerFormat != null && scheme != 'bearer') {
      throw ArgumentError(
        'OpenAPISecurityScheme.http.bearerFormat is only valid when scheme is `bearer`.',
      );
    }
    return OpenAPISecurityScheme._({
      'type': 'http',
      'scheme': scheme,
      'bearerFormat': ?bearerFormat,
      'description': ?description,
      ...?prefixExtensions(extensions),
    });
  }

  /// Creates an `oauth2` security scheme.
  factory OpenAPISecurityScheme.oauth2({
    required OpenAPIOAuthFlows flows,
    String? description,
    Map<String, dynamic>? extensions,
  }) => OpenAPISecurityScheme._({
    'type': 'oauth2',
    'flows': flows,
    'description': ?description,
    ...?prefixExtensions(extensions),
  });

  /// Creates an `openIdConnect` security scheme.
  factory OpenAPISecurityScheme.openIdConnect({
    required String openIdConnectUrl,
    String? description,
    Map<String, dynamic>? extensions,
  }) => OpenAPISecurityScheme._({
    'type': 'openIdConnect',
    'openIdConnectUrl': openIdConnectUrl,
    'description': ?description,
    ...?prefixExtensions(extensions),
  });

  /// Creates a `mutualTLS` security scheme.
  factory OpenAPISecurityScheme.mutualTLS({
    String? description,
    Map<String, dynamic>? extensions,
  }) => OpenAPISecurityScheme._({
    'type': 'mutualTLS',
    'description': ?description,
    ...?prefixExtensions(extensions),
  });
}
