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
    Map<String, dynamic>? extensions,
  }) => OpenAPIInfo._({
    'title': title,
    'version': version,
    ...?switch (summary) {
      final value? => {'summary': value},
      null => null,
    },
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (termsOfService) {
      final value? => {'termsOfService': value},
      null => null,
    },
    ...?switch (contact) {
      final value? => {'contact': value},
      null => null,
    },
    ...?switch (license) {
      final value? => {'license': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIInfo.fromJson(Map<String, dynamic> json) => OpenAPIInfo._({
    'title': _requireString(json, 'title'),
    'version': _requireString(json, 'version'),
    ...?switch (_string(json['summary'])) {
      final value? => {'summary': value},
      null => null,
    },
    ...?switch (_string(json['description'])) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (_string(json['termsOfService'])) {
      final value? => {'termsOfService': value},
      null => null,
    },
    ...?switch (_map(json['contact'])) {
      final value? => {'contact': OpenAPIContact.fromJson(value)},
      null => null,
    },
    ...?switch (_map(json['license'])) {
      final value? => {'license': OpenAPILicense.fromJson(value)},
      null => null,
    },
    ..._extractExtensions(json),
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
    Map<String, dynamic>? extensions,
  }) => OpenAPIContact._({
    ...?switch (name) {
      final value? => {'name': value},
      null => null,
    },
    ...?switch (url) {
      final value? => {'url': value},
      null => null,
    },
    ...?switch (email) {
      final value? => {'email': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIContact.fromJson(Map<String, dynamic> json) =>
      OpenAPIContact._({
        ...?switch (_string(json['name'])) {
          final value? => {'name': value},
          null => null,
        },
        ...?switch (_string(json['url'])) {
          final value? => {'url': value},
          null => null,
        },
        ...?switch (_string(json['email'])) {
          final value? => {'email': value},
          null => null,
        },
        ..._extractExtensions(json),
      });
}

/// OpenAPI `license` object.
extension type OpenAPILicense._(Map<String, Object?> _) {
  /// Creates an OpenAPI license object.
  factory OpenAPILicense({
    required String name,
    String? identifier,
    String? url,
    Map<String, dynamic>? extensions,
  }) {
    _validateExclusiveFields(
      identifier: identifier,
      url: url,
      scope: 'OpenAPILicense',
    );
    return OpenAPILicense._({
      'name': name,
      ...?switch (identifier) {
        final value? => {'identifier': value},
        null => null,
      },
      ...?switch (url) {
        final value? => {'url': value},
        null => null,
      },
      ...?_prefixExtensions(extensions),
    });
  }

  /// Wraps decoded JSON.
  factory OpenAPILicense.fromJson(Map<String, dynamic> json) {
    final identifier = _string(json['identifier']);
    final url = _string(json['url']);
    _validateExclusiveFields(
      identifier: identifier,
      url: url,
      scope: 'openapi.document.info.license',
    );
    return OpenAPILicense._({
      'name': _requireString(json, 'name'),
      ...?switch (identifier) {
        final value? => {'identifier': value},
        null => null,
      },
      ...?switch (url) {
        final value? => {'url': value},
        null => null,
      },
      ..._extractExtensions(json),
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
  throw FormatException('Invalid openapi.$key: expected a string.');
}

Map<String, dynamic>? _map(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Invalid openapi value: expected a JSON object.');
}

String? _string(Object? value) => value is String ? value : null;
