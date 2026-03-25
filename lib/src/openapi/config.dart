import 'components.dart';
import 'info.dart';
import 'path_item.dart';
import 'security.dart';
import 'server.dart';
import 'tag.dart';

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
    OpenAPIComponents? components,
    List<OpenAPIServer>? servers,
    Map<String, OpenAPIPathItem>? webhooks,
    List<OpenAPITag>? tags,
    List<OpenAPISecurityRequirement>? security,
    OpenAPIExternalDocs? externalDocs,
    String? jsonSchemaDialect,
    Map<String, dynamic>? extensions,
  }) => OpenAPIDocumentConfig._({
    'info': info,
    'components': ?components,
    'servers': ?servers,
    'webhooks': ?webhooks,
    'tags': ?tags,
    'security': ?security,
    'externalDocs': ?externalDocs,
    'jsonSchemaDialect': ?jsonSchemaDialect,
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIDocumentConfig.fromJson(Map<String, dynamic> json) =>
      OpenAPIDocumentConfig._({
        'info': OpenAPIInfo.fromJson(
          _requireMap(json, 'info', scope: 'openapi.document'),
        ),
        if (json['components'] case final Map<String, dynamic> value)
          'components': OpenAPIComponents.fromJson(value),
        if (json['servers'] != null)
          'servers': _requireList(json, 'servers', scope: 'openapi.document')
              .map(
                (entry) => OpenAPIServer.fromJson(
                  _requireObjectMap(entry, scope: 'openapi.document.servers'),
                ),
              )
              .toList(),
        if (json['webhooks'] != null)
          'webhooks': {
            for (final entry in _requireMap(
              json,
              'webhooks',
              scope: 'openapi.document',
            ).entries)
              entry.key: OpenAPIPathItem.fromJson(
                _requireObjectMap(
                  entry.value,
                  scope: 'openapi.document.webhooks.${entry.key}',
                ),
              ),
          },
        if (json['tags'] != null)
          'tags': _requireList(json, 'tags', scope: 'openapi.document')
              .map(
                (entry) => OpenAPITag.fromJson(
                  _requireObjectMap(entry, scope: 'openapi.document.tags'),
                ),
              )
              .toList(),
        if (json['security'] != null)
          'security': _requireList(json, 'security', scope: 'openapi.document')
              .map(
                (entry) =>
                    OpenAPISecurityRequirement(_requireStringListMap(entry)),
              )
              .toList(),
        if (json['externalDocs'] case final Map<String, dynamic> value)
          'externalDocs': OpenAPIExternalDocs.fromJson(value),
        'jsonSchemaDialect': ?_string(json['jsonSchemaDialect']),
        ..._extractExtensions(json),
      });

  /// OpenAPI info object.
  OpenAPIInfo get info => _['info'] as OpenAPIInfo;

  /// Optional document components.
  OpenAPIComponents? get components => _['components'] as OpenAPIComponents?;

  /// Optional servers list.
  List<OpenAPIServer>? get servers => _['servers'] as List<OpenAPIServer>?;

  /// Optional webhook declarations.
  Map<String, OpenAPIPathItem>? get webhooks =>
      _['webhooks'] as Map<String, OpenAPIPathItem>?;

  /// Optional tags list.
  List<OpenAPITag>? get tags => _['tags'] as List<OpenAPITag>?;

  /// Optional external docs.
  OpenAPIExternalDocs? get externalDocs =>
      _['externalDocs'] as OpenAPIExternalDocs?;

  /// Optional schema dialect.
  String? get jsonSchemaDialect => _['jsonSchemaDialect'] as String?;
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

Map<String, dynamic> _requireObjectMap(Object? value, {required String scope}) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('Invalid $scope: expected a JSON object.');
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

Map<String, List<String>> _requireStringListMap(Object? value) {
  if (value is! Map) {
    throw FormatException(
      'Invalid openapi.security entry: expected a JSON object.',
    );
  }
  return {
    for (final entry in value.entries)
      entry.key as String: (entry.value as List).cast<String>(),
  };
}
