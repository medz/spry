/// OpenAPI `oauth-flow` object.
extension type OpenAPIOAuthFlow._(Map<String, Object?> _) {
  /// Creates an `implicit` OAuth flow.
  factory OpenAPIOAuthFlow.implicit({
    required String authorizationUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, dynamic>? extensions,
  }) => OpenAPIOAuthFlow._({
    'authorizationUrl': authorizationUrl,
    'scopes': scopes,
    ...?switch (refreshUrl) {
      final value? => {'refreshUrl': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Creates a `password` OAuth flow.
  factory OpenAPIOAuthFlow.password({
    required String tokenUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, dynamic>? extensions,
  }) => OpenAPIOAuthFlow._({
    'tokenUrl': tokenUrl,
    'scopes': scopes,
    ...?switch (refreshUrl) {
      final value? => {'refreshUrl': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Creates a `clientCredentials` OAuth flow.
  factory OpenAPIOAuthFlow.clientCredentials({
    required String tokenUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, dynamic>? extensions,
  }) => OpenAPIOAuthFlow._({
    'tokenUrl': tokenUrl,
    'scopes': scopes,
    ...?switch (refreshUrl) {
      final value? => {'refreshUrl': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Creates an `authorizationCode` OAuth flow.
  factory OpenAPIOAuthFlow.authorizationCode({
    required String authorizationUrl,
    required String tokenUrl,
    required Map<String, String> scopes,
    String? refreshUrl,
    Map<String, dynamic>? extensions,
  }) => OpenAPIOAuthFlow._({
    'authorizationUrl': authorizationUrl,
    'tokenUrl': tokenUrl,
    'scopes': scopes,
    ...?switch (refreshUrl) {
      final value? => {'refreshUrl': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
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
    Map<String, dynamic>? extensions,
  }) => OpenAPIOAuthFlows._({
    ...?switch (implicit) {
      final value? => {'implicit': value},
      null => null,
    },
    ...?switch (password) {
      final value? => {'password': value},
      null => null,
    },
    ...?switch (clientCredentials) {
      final value? => {'clientCredentials': value},
      null => null,
    },
    ...?switch (authorizationCode) {
      final value? => {'authorizationCode': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}
