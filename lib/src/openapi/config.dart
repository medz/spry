import '_openapi_utils.dart';
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
  factory OpenAPIOutput.fromJson(Map<String, Object?> json) {
    final type = requireString(json, 'type', scope: 'openapi.output');
    final path = requireString(json, 'path', scope: 'openapi.output');
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
    Map<String, Object?>? extensions,
  }) => OpenAPIDocumentConfig._({
    'info': info,
    'components': ?components,
    'servers': ?servers,
    'webhooks': ?webhooks,
    'tags': ?tags,
    'security': ?security,
    'externalDocs': ?externalDocs,
    'jsonSchemaDialect': ?jsonSchemaDialect,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIDocumentConfig.fromJson(Map<String, Object?> json) =>
      OpenAPIDocumentConfig._({
        'info': OpenAPIInfo.fromJson(
          _requireMap(json, 'info', scope: 'openapi.document'),
        ),
        if (json.containsKey('components'))
          'components': OpenAPIComponents.fromJson(
            _requireMap(json, 'components', scope: 'openapi.document'),
          ),
        if (json.containsKey('servers'))
          'servers': _requireList(json, 'servers', scope: 'openapi.document')
              .map(
                (entry) => OpenAPIServer.fromJson(
                  _requireObjectMap(entry, scope: 'openapi.document.servers'),
                ),
              )
              .toList(),
        if (json.containsKey('webhooks'))
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
        if (json.containsKey('tags'))
          'tags': _requireList(json, 'tags', scope: 'openapi.document')
              .map(
                (entry) => OpenAPITag.fromJson(
                  _requireObjectMap(entry, scope: 'openapi.document.tags'),
                ),
              )
              .toList(),
        if (json.containsKey('security'))
          'security': _requireList(json, 'security', scope: 'openapi.document')
              .map(
                (entry) =>
                    OpenAPISecurityRequirement(_requireStringListMap(entry)),
              )
              .toList(),
        if (json.containsKey('externalDocs'))
          'externalDocs': OpenAPIExternalDocs.fromJson(
            _requireMap(json, 'externalDocs', scope: 'openapi.document'),
          ),
        'jsonSchemaDialect': ?optionalString(
          json,
          'jsonSchemaDialect',
          scope: 'openapi.document',
        ),
        ...extractExtensions(json),
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

  /// Optional document-level security requirements.
  List<OpenAPISecurityRequirement>? get security =>
      _['security'] as List<OpenAPISecurityRequirement>?;

  /// Optional external docs.
  OpenAPIExternalDocs? get externalDocs =>
      _['externalDocs'] as OpenAPIExternalDocs?;

  /// Optional schema dialect.
  String? get jsonSchemaDialect => _['jsonSchemaDialect'] as String?;
}

/// Scalar API reference UI configuration.
extension type Scalar._(Map<String, Object?> _) {
  /// Creates a Scalar UI configuration.
  factory Scalar({
    String route = '/_docs',
    String? theme,
    String? layout,
    String? title,
  }) => Scalar._({
    'type': 'scalar',
    'route': route,
    'theme': ?theme,
    'layout': ?layout,
    'title': ?title,
  });

  /// Wraps decoded JSON.
  factory Scalar.fromJson(Map<String, Object?> json) => Scalar._({
    'type': 'scalar',
    'route': optionalString(json, 'route', scope: 'openapi.ui') ?? '/_docs',
    'theme': ?optionalString(json, 'theme', scope: 'openapi.ui'),
    'layout': ?optionalString(json, 'layout', scope: 'openapi.ui'),
    'title': ?optionalString(json, 'title', scope: 'openapi.ui'),
  });

  /// Route path where the docs UI is served (default `'/_docs'`).
  String get route => _['route'] as String;

  /// Optional Scalar theme name (e.g. `'moon'`, `'purple'`, `'solarized'`).
  String? get theme => _['theme'] as String?;

  /// Optional Scalar layout variant: `'modern'` (default) or `'classic'`.
  String? get layout => _['layout'] as String?;

  /// Optional page title override; defaults to the document `info.title`.
  String? get title => _['title'] as String?;
}

/// Global OpenAPI generation settings for `spry.config.dart`.
extension type OpenAPIConfig._(Map<String, Object?> _) {
  /// Creates an OpenAPI config object.
  factory OpenAPIConfig({
    required OpenAPIDocumentConfig document,
    OpenAPIOutput? output,
    OpenAPIComponentsMergeStrategy componentsMergeStrategy =
        OpenAPIComponentsMergeStrategy.strict,
    Scalar? ui,
  }) => OpenAPIConfig._({
    'document': document,
    'output': output ?? OpenAPIOutput.route('openapi.json'),
    'componentsMergeStrategy': componentsMergeStrategy.name,
    'ui': ?ui,
  });

  /// Wraps decoded JSON.
  factory OpenAPIConfig.fromJson(Map<String, Object?> json) => OpenAPIConfig._({
    'document': OpenAPIDocumentConfig.fromJson(
      _requireMap(json, 'document', scope: 'openapi'),
    ),
    'output': json['output'] == null
        ? OpenAPIOutput.route('openapi.json')
        : OpenAPIOutput.fromJson(_requireMap(json, 'output', scope: 'openapi')),
    'componentsMergeStrategy': _readMergeStrategy(
      json['componentsMergeStrategy'],
    ).name,
    if (json.containsKey('ui') && json['ui'] != null)
      'ui': Scalar.fromJson(_requireMap(json, 'ui', scope: 'openapi')),
  });

  /// Document metadata seed.
  OpenAPIDocumentConfig get document => _['document'] as OpenAPIDocumentConfig;

  /// Output settings.
  OpenAPIOutput get output => _['output'] as OpenAPIOutput;

  /// Components merge strategy.
  OpenAPIComponentsMergeStrategy get componentsMergeStrategy =>
      _readMergeStrategy(_['componentsMergeStrategy']);

  /// Optional UI configuration; when non-null a docs viewer route is generated.
  Scalar? get ui => _['ui'] as Scalar?;
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

Map<String, Object?> _requireMap(
  Map<String, Object?> json,
  String key, {
  required String scope,
}) {
  if (!json.containsKey(key)) {
    throw FormatException('Missing required $scope.$key');
  }
  final value = json[key];
  if (value == null) {
    throw FormatException(
      'Invalid $scope.$key: expected a JSON object but was null',
    );
  }
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Invalid $scope.$key: expected a JSON object.');
}

List<Object?> _requireList(
  Map<String, Object?> json,
  String key, {
  required String scope,
}) {
  final value = json[key];
  if (value is List) {
    return value.cast<Object?>();
  }
  throw FormatException('Invalid $scope.$key: expected a JSON array.');
}

Map<String, Object?> _requireObjectMap(Object? value, {required String scope}) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Invalid $scope: expected a JSON object.');
}

Map<String, List<String>> _requireStringListMap(Object? value) {
  if (value is! Map) {
    throw FormatException(
      'Invalid openapi.security entry: expected a JSON object.',
    );
  }
  final result = <String, List<String>>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw FormatException(
        'Invalid openapi.security entry key: expected a string, got ${entry.key.runtimeType}.',
      );
    }
    final key = entry.key as String;
    if (entry.value is! List) {
      throw FormatException(
        'Invalid openapi.security.$key: expected an array of strings.',
      );
    }
    final list = <String>[];
    for (final item in entry.value as List) {
      if (item is! String) {
        throw FormatException(
          'Invalid openapi.security.$key entry: expected a string, got ${item.runtimeType}.',
        );
      }
      list.add(item);
    }
    result[key] = list;
  }
  return result;
}
