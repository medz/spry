import '_openapi_utils.dart';

/// OpenAPI `oauth-flow` object.
extension type OpenAPIOAuthFlow._(Map<String, Object?> _) {
  /// Creates an `implicit` OAuth flow.
  factory OpenAPIOAuthFlow.implicit({
    required String authorizationUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, Object?>? extensions,
  }) => OpenAPIOAuthFlow._({
    'authorizationUrl': authorizationUrl,
    'scopes': Map<String, String>.unmodifiable(scopes),
    'refreshUrl': ?refreshUrl,
    ...?prefixExtensions(extensions),
  });

  /// Creates a `password` OAuth flow.
  factory OpenAPIOAuthFlow.password({
    required String tokenUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, Object?>? extensions,
  }) => OpenAPIOAuthFlow._({
    'tokenUrl': tokenUrl,
    'scopes': Map<String, String>.unmodifiable(scopes),
    'refreshUrl': ?refreshUrl,
    ...?prefixExtensions(extensions),
  });

  /// Creates a `clientCredentials` OAuth flow.
  factory OpenAPIOAuthFlow.clientCredentials({
    required String tokenUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, Object?>? extensions,
  }) => OpenAPIOAuthFlow._({
    'tokenUrl': tokenUrl,
    'scopes': Map<String, String>.unmodifiable(scopes),
    'refreshUrl': ?refreshUrl,
    ...?prefixExtensions(extensions),
  });

  /// Creates an `authorizationCode` OAuth flow.
  factory OpenAPIOAuthFlow.authorizationCode({
    required String authorizationUrl,
    required String tokenUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, Object?>? extensions,
  }) => OpenAPIOAuthFlow._({
    'authorizationUrl': authorizationUrl,
    'tokenUrl': tokenUrl,
    'scopes': Map<String, String>.unmodifiable(scopes),
    'refreshUrl': ?refreshUrl,
    ...?prefixExtensions(extensions),
  });
}

/// OpenAPI `oauth-flows` object.
extension type OpenAPIOAuthFlows._(Map<String, Object?> _) {
  /// Creates an OAuth flows object.
  factory OpenAPIOAuthFlows({
    OpenAPIOAuthFlow? implicit,
    OpenAPIOAuthFlow? password,
    OpenAPIOAuthFlow? clientCredentials,
    OpenAPIOAuthFlow? authorizationCode,
    Map<String, Object?>? extensions,
  }) => OpenAPIOAuthFlows._({
    'implicit': ?implicit,
    'password': ?password,
    'clientCredentials': ?clientCredentials,
    'authorizationCode': ?authorizationCode,
    ...?prefixExtensions(extensions),
  });
}
