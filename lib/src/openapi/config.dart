import 'info.dart';

/// Controls how document-level components are merged.
enum OpenAPIComponentsMergeStrategy {
  /// Deduplicate identical definitions and reject incompatible collisions.
  strict,

  /// Allow recursive map merges for same-name components.
  deepMerge,
}

/// Describes where `openapi.json` should be written.
extension type OpenAPIOutput._(Map<String, Object?> _) {
  /// Writes the document into the public directory.
  factory OpenAPIOutput.route(String path) =>
      OpenAPIOutput._({'type': 'route', 'path': path});

  /// Writes the document to a local path relative to the project root.
  factory OpenAPIOutput.local(String path) =>
      OpenAPIOutput._({'type': 'local', 'path': path});

  /// Wraps decoded JSON.
  factory OpenAPIOutput.fromJson(Map<String, dynamic> json) {
    final type = _requireString(json, 'type', scope: 'openapi.output');
    final path = _requireString(json, 'path', scope: 'openapi.output');
    return switch (type) {
      'route' => OpenAPIOutput.route(path),
      'local' => OpenAPIOutput.local(path),
      _ => throw FormatException(
        'Invalid openapi.output.type: expected `route` or `local`.',
      ),
    };
  }

  /// Output type identifier.
  String get type => _['type'] as String;

  /// Target path.
  String get path => _['path'] as String;
}

/// Configurable document root fields excluding generated paths.
extension type OpenAPIDocumentConfig._(Map<String, Object?> _) {
  /// Creates an OpenAPI document config seed.
  factory OpenAPIDocumentConfig({
    required OpenAPIInfo info,
    Object? components,
    List<Object?>? servers,
    Map<String, Object?>? webhooks,
    List<Object?>? tags,
    List<Object?>? security,
    Object? externalDocs,
    String? jsonSchemaDialect,
    Map<String, dynamic>? extensions,
  }) => OpenAPIDocumentConfig._({
    'info': info,
    ...?switch (components) {
      final value? => {'components': value},
      null => null,
    },
    ...?switch (servers) {
      final value? => {'servers': value},
      null => null,
    },
    ...?switch (webhooks) {
      final value? => {'webhooks': value},
      null => null,
    },
    ...?switch (tags) {
      final value? => {'tags': value},
      null => null,
    },
    ...?switch (security) {
      final value? => {'security': value},
      null => null,
    },
    ...?switch (externalDocs) {
      final value? => {'externalDocs': value},
      null => null,
    },
    ...?switch (jsonSchemaDialect) {
      final value? => {'jsonSchemaDialect': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIDocumentConfig.fromJson(Map<String, dynamic> json) =>
      OpenAPIDocumentConfig._({
        'info': OpenAPIInfo.fromJson(
          _requireMap(json, 'info', scope: 'openapi.document'),
        ),
        if (json['components'] != null) 'components': json['components'],
        if (json['servers'] != null)
          'servers': _requireList(json, 'servers', scope: 'openapi.document'),
        if (json['webhooks'] != null)
          'webhooks': _requireMap(json, 'webhooks', scope: 'openapi.document'),
        if (json['tags'] != null)
          'tags': _requireList(json, 'tags', scope: 'openapi.document'),
        if (json['security'] != null)
          'security': _requireList(json, 'security', scope: 'openapi.document'),
        if (json['externalDocs'] != null) 'externalDocs': json['externalDocs'],
        ...?switch (_string(json['jsonSchemaDialect'])) {
          final dialect? => {'jsonSchemaDialect': dialect},
          null => null,
        },
        ..._extractExtensions(json),
      });

  /// OpenAPI info object.
  OpenAPIInfo get info => _['info'] as OpenAPIInfo;
}

/// Global OpenAPI generation settings for `spry.config.dart`.
extension type OpenAPIConfig._(Map<String, Object?> _) {
  /// Creates an OpenAPI config object.
  factory OpenAPIConfig({
    required OpenAPIDocumentConfig document,
    OpenAPIOutput? output,
    OpenAPIComponentsMergeStrategy componentsMergeStrategy =
        OpenAPIComponentsMergeStrategy.strict,
  }) => OpenAPIConfig._({
    'document': document,
    'output': output ?? OpenAPIOutput.route('openapi.json'),
    'componentsMergeStrategy': componentsMergeStrategy.name,
  });

  /// Wraps decoded JSON.
  factory OpenAPIConfig.fromJson(Map<String, dynamic> json) => OpenAPIConfig._({
    'document': OpenAPIDocumentConfig.fromJson(
      _requireMap(json, 'document', scope: 'openapi'),
    ),
    'output': json['output'] == null
        ? OpenAPIOutput.route('openapi.json')
        : OpenAPIOutput.fromJson(_requireMap(json, 'output', scope: 'openapi')),
    'componentsMergeStrategy': _readMergeStrategy(
      json['componentsMergeStrategy'],
    ).name,
  });

  /// Document metadata seed.
  OpenAPIDocumentConfig get document => _['document'] as OpenAPIDocumentConfig;

  /// Output settings.
  OpenAPIOutput get output => _['output'] as OpenAPIOutput;

  /// Components merge strategy.
  OpenAPIComponentsMergeStrategy get componentsMergeStrategy =>
      _readMergeStrategy(_['componentsMergeStrategy']);
}

OpenAPIComponentsMergeStrategy _readMergeStrategy(Object? value) {
  return switch (value) {
    null => OpenAPIComponentsMergeStrategy.strict,
    OpenAPIComponentsMergeStrategy() => value,
    String() => OpenAPIComponentsMergeStrategy.values.firstWhere(
      (strategy) => strategy.name == value,
      orElse: () => throw FormatException(
        'Invalid openapi.componentsMergeStrategy: expected one of ${OpenAPIComponentsMergeStrategy.values.map((it) => it.name).join(', ')}.',
      ),
    ),
    _ => throw FormatException(
      'Invalid openapi.componentsMergeStrategy: expected a string.',
    ),
  };
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

Map<String, dynamic> _requireMap(
  Map<String, dynamic> json,
  String key, {
  required String scope,
}) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Invalid $scope.$key: expected a JSON object.');
}

List<Object?> _requireList(
  Map<String, dynamic> json,
  String key, {
  required String scope,
}) {
  final value = json[key];
  if (value is List) {
    return value.cast<Object?>();
  }
  throw FormatException('Invalid $scope.$key: expected a JSON array.');
}

String _requireString(
  Map<String, dynamic> json,
  String key, {
  required String scope,
}) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Invalid $scope.$key: expected a string.');
}

String? _string(Object? value) => value is String ? value : null;
