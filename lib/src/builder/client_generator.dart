import 'dart:io';
import 'dart:isolate';

import 'package:ht/ht.dart' show Headers;
import 'package:path/path.dart' as p;

import '../../config.dart' show ClientConfig;
import 'config.dart';
import 'generated_entry.dart';
import 'scan_entry.dart';
import 'scan_state.dart';

/// Resolves the generated client package directory for the current build.
String resolveClientPkgDir(BuildConfig config, ClientConfig client) {
  return p.normalize(p.absolute(config.rootDir, client.pkgDir));
}

/// Resolves the generated client library output directory inside the package.
String resolveClientOutputDir(String pkgDir, ClientConfig client) {
  return p.normalize(p.absolute(pkgDir, client.output));
}

/// Creates a minimal client pubspec when the package does not yet have one.
Future<void> ensureClientPubspec(String pkgDir) async {
  final pubspec = File(p.join(pkgDir, 'pubspec.yaml'));
  if (await pubspec.exists()) {
    return;
  }

  await pubspec.parent.create(recursive: true);
  await pubspec.writeAsString(_clientPubspec(pkgDir));
}

String _clientPubspec(String pkgDir) {
  return '''
name: ${_packageName(pkgDir)}
publish_to: none
description: Generated Spry client package.

environment:
  sdk: ^3.10.0
''';
}

String _packageName(String pkgDir) {
  final normalized = p
      .basename(pkgDir)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (normalized.isEmpty) {
    return 'spry_client';
  }
  if (RegExp(r'^[0-9]').hasMatch(normalized)) {
    return 'pkg_$normalized';
  }
  return normalized;
}

/// Ensures the generated client package depends on the current Spry version.
Future<void> ensureSpryDependency(String pkgDir) async {
  final descriptor = await _spryHostedDependencyDescriptor();
  final offlineResult = await _runPubAdd(pkgDir, descriptor, offline: true);
  if (offlineResult.exitCode == 0) {
    return;
  }

  final onlineResult = await _runPubAdd(pkgDir, descriptor, offline: false);
  if (onlineResult.exitCode == 0) {
    return;
  }

  final error = switch ((onlineResult.stderr as String).trim()) {
    '' => (onlineResult.stdout as String).trim(),
    final stderr => stderr,
  };
  throw StateError(error);
}

Future<ProcessResult> _runPubAdd(
  String pkgDir,
  String descriptor, {
  required bool offline,
}) {
  return Process.run(
    Platform.resolvedExecutable,
    ['pub', 'add', if (offline) '--offline', '--no-example', descriptor],
    workingDirectory: pkgDir,
    runInShell: Platform.isWindows,
  );
}

Future<String> _spryHostedDependencyDescriptor() async {
  final libraryUri = await Isolate.resolvePackageUri(
    Uri.parse('package:spry/spry.dart'),
  );
  if (libraryUri == null) {
    throw StateError('Failed to resolve package:spry/spry.dart.');
  }

  final packageRoot = p.normalize(
    p.join(p.dirname(libraryUri.toFilePath()), '..'),
  );
  final pubspec = await File(
    p.join(packageRoot, 'pubspec.yaml'),
  ).readAsString();
  final version = RegExp(
    r'^version:\s*([^\s#]+)',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  if (version == null || version.isEmpty) {
    throw StateError('Failed to resolve the current spry package version.');
  }
  return 'spry:^$version';
}

/// Generates client source artifacts for the collected scan state.
Stream<GeneratedEntry> generateClientEntries(
  ScanState state,
  BuildConfig config,
) async* {
  final client = config.client;
  if (client == null) {
    return;
  }
  final routesRootDir = p.normalize(p.absolute(config.rootDir, 'routes'));
  final pkgDir = resolveClientPkgDir(config, client);
  final outputDir = resolveClientOutputDir(pkgDir, client);
  final routes = _buildClientRoutes(state, routesRootDir);
  final models = _buildClientModels(routes);
  final typedData = _buildClientTypedData(routes, routesRootDir, models);

  yield _clientSourceEntry(
    config.rootDir,
    outputDir,
    'client.dart',
    _clientEntry(client, routes),
  );
  yield _clientSourceEntry(
    config.rootDir,
    outputDir,
    'routes.dart',
    _routesLibrary(routes),
  );
  yield _clientSourceEntry(
    config.rootDir,
    outputDir,
    'params.dart',
    _paramsLibrary(routes),
  );
  yield _clientSourceEntry(
    config.rootDir,
    outputDir,
    'inputs.dart',
    _inputsLibrary(typedData.inputFiles.values),
  );
  yield _clientSourceEntry(
    config.rootDir,
    outputDir,
    'models.dart',
    _modelsLibrary(models.filesByName.values),
  );
  for (final node in _routeNodes(routes)) {
    yield _clientSourceEntry(
      config.rootDir,
      outputDir,
      node.filePath,
      _routeEntry(node, typedData.routeDataTypes),
    );
  }
  for (final node in _paramNodes(routes)) {
    yield _clientSourceEntry(
      config.rootDir,
      outputDir,
      node.paramsFilePath,
      _paramsEntry(node),
    );
  }
  for (final input in typedData.inputFiles.values) {
    yield _clientSourceEntry(
      config.rootDir,
      outputDir,
      input.filePath,
      input.source,
    );
  }
  for (final model in models.filesByName.values) {
    yield _clientSourceEntry(
      config.rootDir,
      outputDir,
      model.filePath,
      model.source,
    );
  }
}

GeneratedEntry _clientSourceEntry(
  String rootDir,
  String outputDir,
  String relativePath,
  String content,
) {
  return GeneratedEntry(
    type: GeneratedEntryType.clientSource,
    path: p
        .relative(p.join(outputDir, relativePath), from: rootDir)
        .replaceAll('\\', '/'),
    content: content,
    rootRelative: true,
  );
}

String _clientEntry(ClientConfig client, _ClientRootRoutes routes) {
  final imports = [
    "import 'package:spry/client.dart';",
    "import 'routes.dart';",
  ].join('\n');

  final directives = [
    "export 'routes.dart';",
    "export 'params.dart';",
    "export 'inputs.dart';",
    "export 'models.dart';",
  ].join('\n');

  final clientBody = [
    _clientConstructor(client),
    ?_clientGlobalHeadersMember(client),
    ..._rootNamespaceMembers(routes),
  ].join('\n');

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$imports

$directives

/// Generated client entry.
class SpryClient extends BaseSpryClient {
$clientBody
}
''';
}

String _clientConstructor(ClientConfig client) {
  return switch ((client.endpoint, client.headers)) {
    (null, null) =>
      '  /// Creates a generated client shell.\n  SpryClient({required super.endpoint, super.headers});',
    (null, Headers()) =>
      '  /// Creates a generated client shell.\n  SpryClient({required super.endpoint, super.headers});',
    (final String endpoint, _) =>
      '''
  /// Creates a generated client shell.
  SpryClient({Uri? endpoint, super.headers})
    : super(endpoint: endpoint ?? Uri.parse(${_dartString(endpoint)}));''',
  };
}

String? _clientGlobalHeadersMember(ClientConfig client) {
  final headers = client.headers;
  if (headers == null) {
    return null;
  }
  return '''

  @override
  final globalHeaders = Headers(${_dartHeadersLiteral(headers)});''';
}

Iterable<String> _rootNamespaceMembers(_ClientRootRoutes routes) sync* {
  if (routes.root != null) {
    yield '';
    yield "  /// Route namespace for `${routes.root!.routePath}`.";
    yield '  late final root = ${routes.root!.className}(this);';
  }

  for (final node in routes.children) {
    yield '';
    yield "  /// Route namespace for `${node.routePath}`.";
    yield '  late final ${node.propertyName} = ${node.className}(this);';
  }
}

String _routesLibrary(_ClientRootRoutes routes) {
  final exports = [
    for (final node in _routeNodes(routes)) "export '${node.filePath}';",
  ].join('\n');
  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$exports
''';
}

String _paramsLibrary(_ClientRootRoutes routes) {
  final exports = [
    for (final node in _paramNodes(routes)) "export '${node.paramsFilePath}';",
  ].join('\n');
  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$exports
''';
}

String _inputsLibrary(Iterable<_ClientInputFile> inputs) {
  final exports = [
    for (final input in [
      ...inputs,
    ]..sort((a, b) => a.filePath.compareTo(b.filePath)))
      "export '${input.filePath}';",
  ].join('\n');
  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$exports
''';
}

String _modelsLibrary(Iterable<_ClientModelFile> models) {
  final exports = [
    for (final model in [
      ...models,
    ]..sort((a, b) => a.filePath.compareTo(b.filePath)))
      "export '${model.filePath}';",
  ].join('\n');
  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$exports
''';
}

_ClientModelRegistry _buildClientModels(_ClientRootRoutes routes) {
  final models = _ClientModelRegistry();
  for (final node in _routeNodes(routes)) {
    for (final route in node.routes) {
      models.registerComponents(_routeComponents(route));
    }
  }
  return models;
}

Iterable<_ClientRouteNode> _routeNodes(_ClientRootRoutes routes) sync* {
  if (routes.root case final root?) {
    yield root;
    yield* _routeNodesFor(root);
  }

  for (final node in routes.children) {
    yield node;
    yield* _routeNodesFor(node);
  }
}

Iterable<_ClientRouteNode> _routeNodesFor(_ClientRouteNode node) sync* {
  for (final child in node.children) {
    yield child;
    yield* _routeNodesFor(child);
  }
}

Iterable<_ClientRouteNode> _paramNodes(_ClientRootRoutes routes) sync* {
  for (final node in _routeNodes(routes)) {
    if (_ownsParams(node)) {
      yield node;
    }
  }
}

_ClientTypedDataBuildResult _buildClientTypedData(
  _ClientRootRoutes routes,
  String routesRootDir,
  _ClientModelRegistry models,
) {
  final routeDataTypes = <RouteEntry, _ClientTypedDataRef>{};
  final inputFiles = <String, _ClientInputFile>{};
  for (final node in _routeNodes(routes)) {
    for (final route in node.routes) {
      final dataType = _buildClientTypedDataForRoute(
        route,
        node,
        routesRootDir,
        models,
      );
      if (dataType != null) {
        routeDataTypes[route] = dataType.reference;
        if (dataType.inputFile case final inputFile?) {
          inputFiles[inputFile.filePath] = inputFile;
        }
      }
    }
  }
  return _ClientTypedDataBuildResult(
    routeDataTypes: routeDataTypes,
    inputFiles: inputFiles,
  );
}

_ClientTypedDataResult? _buildClientTypedDataForRoute(
  RouteEntry route,
  _ClientRouteNode node,
  String routesRootDir,
  _ClientModelRegistry models,
) {
  final schema = _typedJsonRequestSchema(route);
  if (schema == null) {
    return null;
  }

  final className = _inputClassName(route, node);
  final inputType = _parseClientInputType(
    schema,
    className: className,
    context: _ClientInputParseContext(
      components: _routeComponents(route),
      models: models,
      objectTypesByShape: {...models.objectTypesByShape},
    ),
  );
  if (inputType == null) {
    return null;
  }
  if (inputType case _ClientInputObjectType(
    isModel: true,
    filePath: final filePath?,
  )) {
    return _ClientTypedDataResult(
      reference: _ClientTypedDataRef(
        typeName: inputType.className,
        filePath: filePath,
      ),
    );
  }

  final inputFile = _ClientInputFile(
    filePath:
        'inputs/${_sourceOperationFileSegments(route, routesRootDir).join('/')}.dart',
    typeName: className,
    source: _inputEntry(
      inputType,
      className,
      filePath:
          'inputs/${_sourceOperationFileSegments(route, routesRootDir).join('/')}.dart',
    ),
  );
  return _ClientTypedDataResult(
    reference: _ClientTypedDataRef(
      typeName: inputFile.typeName,
      filePath: inputFile.filePath,
    ),
    inputFile: inputFile,
  );
}

String _routeEntry(
  _ClientRouteNode node,
  Map<RouteEntry, _ClientTypedDataRef> routeDataTypes,
) {
  final paramImports = {
    if (node.routes.isNotEmpty)
      if (_paramsOwner(node) case final owner?)
        _relativeRouteImport(node.filePath, owner.paramsFilePath),
  };
  final inputImports = {
    for (final route in node.routes)
      if (routeDataTypes[route] case final dataType?)
        _relativeRouteImport(node.filePath, dataType.filePath),
  };
  final imports = [
    if (node.routes.isNotEmpty) "import 'dart:async';",
    "import 'package:spry/client.dart';",
    for (final import in paramImports) "import '$import';",
    for (final import in inputImports) "import '$import';",
    for (final child in node.children)
      "import '${_relativeRouteImport(node.filePath, child.filePath)}';",
  ].join('\n');

  final members = <String>['  ${node.className}(super.client);'];

  for (final child in node.children) {
    members
      ..add('')
      ..add('  late final ${child.propertyName} = ${child.className}(client);');
  }

  if (node.routes.length == 1) {
    members
      ..add('')
      ..add(_callMethodDefinition(node.routes.single, node, routeDataTypes));
  } else {
    for (final route in node.routes) {
      members
        ..add('')
        ..add(_routeMethodDefinition(route, node, routeDataTypes));
    }
  }

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$imports
class ${node.className} extends ClientRoutes {
${members.join('\n')}
}''';
}

String _paramsEntry(_ClientRouteNode node) {
  final base = _paramsBaseNode(node);
  final imports = [
    if (base != null)
      "import '${_relativeRouteImport(node.paramsFilePath, base.paramsFilePath)}';",
  ].join('\n');
  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

${imports.isEmpty ? '' : '$imports\n'}
${_paramsTypeDefinition(node)}
''';
}

String _inputEntry(
  _ClientInputType inputType,
  String className, {
  required String filePath,
}) {
  final modelImports = <String>{};
  for (final objectType in _directModelDependencies(
    inputType,
    includeRootModel: true,
    expandModelFields: false,
  )) {
    final objectFilePath = objectType.filePath!;
    modelImports.add(
      "import '${_relativeRouteImport(filePath, objectFilePath)}';",
    );
  }
  final objectTypesByClassName = <String, _ClientInputObjectType>{};
  for (final objectType in inputType.objectTypes) {
    if (objectType.isModel) {
      continue;
    }
    objectTypesByClassName.putIfAbsent(objectType.className, () => objectType);
  }
  final definitions = <String>[
    for (final objectType in objectTypesByClassName.values)
      _inputObjectDefinition(objectType),
    if (inputType is! _ClientInputObjectType)
      'typedef $className = ${inputType.typeAnnotation()};',
  ].join('\n\n');

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

${modelImports.isEmpty ? '' : '${modelImports.join('\n')}\n\n'}$definitions
''';
}

String _modelEntry(_ClientInputObjectType model) {
  final imports = <String>{};
  for (final objectType in _directModelDependencies(
    model,
    expandModelFields: true,
  )) {
    final objectFilePath = objectType.filePath!;
    if (objectFilePath == model.filePath) {
      continue;
    }
    imports.add(
      "import '${_relativeRouteImport(model.filePath!, objectFilePath)}';",
    );
  }
  final objectTypesByClassName = <String, _ClientInputObjectType>{};
  for (final objectType in model.objectTypes) {
    if (objectType.isModel) {
      continue;
    }
    objectTypesByClassName.putIfAbsent(objectType.className, () => objectType);
  }

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

${imports.isEmpty ? '' : '${imports.join('\n')}\n\n'}${[for (final objectType in objectTypesByClassName.values) _inputObjectDefinition(objectType), _inputObjectDefinition(model)].join('\n\n')}
''';
}

Set<_ClientInputObjectType> _directModelDependencies(
  _ClientInputType type, {
  bool includeRootModel = false,
  required bool expandModelFields,
}) {
  final models = <_ClientInputObjectType>{};

  void visit(_ClientInputType current, {required bool isRoot}) {
    switch (current) {
      case _ClientInputScalarType():
        return;
      case _ClientInputListType(itemType: final itemType):
        visit(itemType, isRoot: false);
      case _ClientInputObjectType(fields: final fields):
        if (current.isModel && (includeRootModel || !isRoot)) {
          models.add(current);
          if (!expandModelFields) {
            return;
          }
        }
        for (final field in fields) {
          final fieldType = field.type;
          if (fieldType case _ClientInputObjectType(isModel: true)) {
            models.add(fieldType);
            continue;
          }
          visit(fieldType, isRoot: false);
        }
    }
  }

  visit(type, isRoot: true);
  return models;
}

String _routeMethodDefinition(
  RouteEntry route,
  _ClientRouteNode node,
  Map<RouteEntry, _ClientTypedDataRef> routeDataTypes,
) {
  final methodName = route.method?.name ?? 'call';
  final parameters = _callParameters(node, route, routeDataTypes);
  return '  Future<Object?> $methodName($parameters) => throw UnimplementedError();';
}

String _callMethodDefinition(
  RouteEntry route,
  _ClientRouteNode node,
  Map<RouteEntry, _ClientTypedDataRef> routeDataTypes,
) {
  final parameters = _callParameters(node, route, routeDataTypes);
  return '  Future<Object?> call($parameters) => throw UnimplementedError();';
}

String _paramsTypeDefinition(_ClientRouteNode node) {
  final className = _paramsClassName(node);
  final base = _paramsBaseNode(node);
  final ownParams = _ownPathParams(node);
  final fields = ownParams
      .map((param) => '  final ${param.type} ${param.name};')
      .join('\n');
  final extendsClause = switch (base) {
    null => '',
    final base => ' extends ${_paramsClassName(base)}',
  };
  final inheritedParameters = switch (base) {
    null => const <String>[],
    final base => base.pathParams.map(
      (param) => param.superConstructorParameter,
    ),
  };
  final ownConstructorParameters = ownParams.map((param) {
    if (param.hasValidation) {
      return param.validatingConstructorParameter;
    }
    return param.constructorParameter;
  });
  final allParameters = [
    ...inheritedParameters,
    ...ownConstructorParameters,
  ].join(', ');

  final validators = ownParams
      .where((param) => param.hasValidation)
      .map(_validatorDefinition)
      .join('\n\n');
  final ownInitializers = ownParams
      .where((param) => param.hasValidation)
      .map((param) => '${param.name} = ${param.initializerExpression}')
      .join(',\n        ');

  final constEligible = !node.pathParams.any((param) => param.hasValidation);
  final constructor = switch ((constEligible, ownInitializers.isEmpty)) {
    (true, _) => '  const $className({$allParameters});',
    (false, true) => '  $className({$allParameters});',
    (false, false) =>
      '  $className({$allParameters})\n      : $ownInitializers;',
  };

  final parts = <String>[
    'class $className$extendsClause {',
    constructor,
    if (fields.isNotEmpty) '',
    if (fields.isNotEmpty) fields,
    if (validators.isNotEmpty) '',
    if (validators.isNotEmpty) validators,
    '}',
  ];
  return '${parts.join('\n')}\n';
}

String _callParameters(
  _ClientRouteNode node,
  RouteEntry route,
  Map<RouteEntry, _ClientTypedDataRef> routeDataTypes,
) {
  final owner = _paramsOwner(node);
  final dataType = routeDataTypes[route];
  final namedParameters = <String>[
    if (owner case final owner?) _paramsCallParameter(owner),
    if (dataType case final dataType?) '${dataType.typeName}? data',
    'BodyInit? body',
    'Headers? headers',
    'URLSearchParams? query',
  ];
  return '{${namedParameters.join(', ')}}';
}

String _paramsCallParameter(_ClientRouteNode node) {
  final className = _paramsClassName(node);
  if (node.pathParams.any((param) => param.required)) {
    return 'required $className params';
  }
  if (node.pathParams.any((param) => param.hasValidation)) {
    return '$className? params';
  }
  return '$className params = const $className()';
}

String _validatorDefinition(_ClientParam param) {
  final methodName = '_validate${_pascal(param.name)}';
  final buffer = StringBuffer()
    ..writeln('  static ${param.type} $methodName(${param.type} value) {');
  if (param.requiresAtLeastOne) {
    buffer
      ..writeln('    if (value.isEmpty) {')
      ..writeln(
        "      throw ArgumentError.value(value, '${param.name}', 'Must contain at least one segment.');",
      )
      ..writeln('    }');
  }
  if (param.regexPattern case final pattern?) {
    final matcher = param.isList
        ? 'value.any((segment) => !_${param.name}Pattern.hasMatch(segment))'
        : switch (param.isNullable) {
            true => 'value != null && !_${param.name}Pattern.hasMatch(value)',
            false => '!_${param.name}Pattern.hasMatch(value)',
          };
    final message = param.isList
        ? 'All segments must match /$pattern/.'
        : 'Must match /$pattern/.';
    buffer
      ..writeln('    if ($matcher) {')
      ..writeln(
        "      throw ArgumentError.value(value, '${param.name}', ${_dartString(message)});",
      )
      ..writeln('    }')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln()
      ..write(
        "  static final _${param.name}Pattern = RegExp(${_dartString('^(?:$pattern)\$')});",
      );
    return buffer.toString();
  }
  buffer
    ..writeln('    return value;')
    ..write('  }');
  return buffer.toString();
}

Map<String, Object?>? _typedJsonRequestSchema(RouteEntry route) {
  final openapi = route.openapi;
  if (openapi == null) {
    return null;
  }
  final requestBody = _resolveRequestBody(
    openapi['requestBody'],
    components: _routeComponents(route),
  );
  if (requestBody is! Map<String, Object?>) {
    return null;
  }
  final content = requestBody['content'];
  if (content is! Map<String, Object?> ||
      content.length != 1 ||
      !content.containsKey('application/json')) {
    return null;
  }
  final mediaType = content['application/json'];
  if (mediaType is! Map<String, Object?>) {
    return null;
  }
  final schema = mediaType['schema'];
  if (schema is! Map<String, Object?>) {
    return null;
  }
  return schema;
}

Map<String, Object?> _routeComponents(RouteEntry route) {
  if (route.openapi?['x-spry-openapi-global-components']
      case final Map<String, Object?> components) {
    return components;
  }
  return const {};
}

Object? _resolveRequestBody(
  Object? requestBody, {
  required Map<String, Object?> components,
}) {
  if (requestBody is! Map<String, Object?>) {
    return requestBody;
  }
  if (requestBody[r'$ref'] case final String ref) {
    return _resolveComponentRef(ref, components: components);
  }
  return requestBody;
}

Object? _resolveComponentRef(
  String ref, {
  required Map<String, Object?> components,
}) {
  final match = RegExp(r'^#/components/([^/]+)/([^/]+)$').firstMatch(ref);
  if (match == null) {
    return null;
  }
  final section = match.group(1)!;
  final key = match.group(2)!;
  if (components[section] case final Map<String, Object?> values) {
    return values[key];
  }
  return null;
}

_ClientInputType? _parseClientInputType(
  Object? schema, {
  required String className,
  required _ClientInputParseContext context,
}) {
  if (schema is! Map<String, Object?>) {
    return null;
  }
  if (schema[r'$ref'] case final String ref) {
    if (ref.startsWith('#/components/schemas/')) {
      final name = ref.substring('#/components/schemas/'.length);
      final model = context.models?.resolveSchema(name, context.components);
      if (model != null) {
        return model;
      }
    }
    final resolved = _resolveComponentRef(ref, components: context.components);
    if (resolved == null) {
      return null;
    }
    return _parseClientInputType(
      resolved,
      className: className,
      context: context,
    );
  }
  if (schema.containsKey(r'$ref') ||
      schema.containsKey('oneOf') ||
      schema.containsKey('anyOf') ||
      schema.containsKey('allOf')) {
    return null;
  }

  final typeInfo = _schemaTypeInfo(schema);
  if (typeInfo == null) {
    return null;
  }

  switch (typeInfo.type) {
    case 'string':
      return _ClientInputScalarType(
        dartType: switch (schema['format']) {
          'date-time' => 'DateTime',
          _ => 'String',
        },
        nullable: typeInfo.nullable,
        isDateTime: schema['format'] == 'date-time',
      );
    case 'integer':
      return _ClientInputScalarType(
        dartType: 'int',
        nullable: typeInfo.nullable,
      );
    case 'number':
      return _ClientInputScalarType(
        dartType: 'double',
        nullable: typeInfo.nullable,
      );
    case 'boolean':
      return _ClientInputScalarType(
        dartType: 'bool',
        nullable: typeInfo.nullable,
      );
    case 'array':
      final items = schema['items'];
      final itemType = _parseClientInputType(
        items,
        className: _nestedTypeClassName(className, 'Item'),
        context: context,
      );
      if (itemType == null) {
        return null;
      }
      return _ClientInputListType(
        itemType: itemType,
        nullable: typeInfo.nullable,
      );
    case 'object':
      final rawProperties = schema['properties'];
      if (rawProperties is! Map<String, Object?>) {
        return _ClientInputObjectType(
          className: className,
          nullable: typeInfo.nullable,
          fields: const [],
          isModel: false,
        );
      }
      final requiredProperties = _requiredSchemaProperties(schema);
      final usedFieldNames = <String>{};
      final fields = <_ClientInputField>[];
      for (final MapEntry(:key, :value) in rawProperties.entries) {
        final fieldName = _uniqueParamName(
          _inputFieldName(key),
          usedFieldNames,
        );
        usedFieldNames.add(fieldName);
        final fieldType = _parseClientInputType(
          value,
          className: _nestedTypeClassName(className, _pascal(fieldName)),
          context: context,
        );
        if (fieldType == null) {
          return null;
        }
        fields.add(
          _ClientInputField(
            name: fieldName,
            jsonName: key,
            type: fieldType,
            required: requiredProperties.contains(key),
          ),
        );
      }
      final input = _ClientInputObjectType(
        className: className,
        nullable: typeInfo.nullable,
        fields: fields,
        isModel: false,
      );
      final canonical = context.objectTypesByShape.putIfAbsent(
        input.definitionKey,
        () => input.copyWith(nullable: false),
      );
      return canonical.copyWith(nullable: typeInfo.nullable);
    default:
      return null;
  }
}

_SchemaTypeInfo? _schemaTypeInfo(Map<String, Object?> schema) {
  final type = schema['type'];
  switch (type) {
    case final String value:
      return _SchemaTypeInfo(value, false);
    case final List<Object?> values:
      final nonNullTypes = values
          .whereType<String>()
          .where((value) => value != 'null')
          .toList();
      final nullable = values.contains('null');
      if (nonNullTypes.length != 1) {
        return null;
      }
      return _SchemaTypeInfo(nonNullTypes.single, nullable);
    default:
      return null;
  }
}

Set<String> _requiredSchemaProperties(Map<String, Object?> schema) {
  final raw = switch (schema['requiredProperties']) {
    final List<Object?> values => values,
    _ => switch (schema['required']) {
      final List<Object?> values => values,
      _ => const <Object?>[],
    },
  };
  return raw.whereType<String>().toSet();
}

String _inputClassName(RouteEntry route, _ClientRouteNode node) {
  return switch (route.method) {
    null => '${node.classStem.join()}Input',
    final method => '${_pascal(method.name)}${node.classStem.join()}Input',
  };
}

String _inputClassStem(String className) {
  return className.endsWith('Input')
      ? className.substring(0, className.length - 'Input'.length)
      : className;
}

String _nestedTypeClassName(String className, String suffix) {
  final stem = _inputClassStem(className);
  if (className.endsWith('Input')) {
    return '$stem${suffix}Input';
  }
  return '$stem$suffix';
}

String _inputFieldName(String value) {
  if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value)) {
    return '${value[0].toLowerCase()}${value.substring(1)}';
  }
  final words = RegExp(
    r'[A-Za-z0-9]+',
  ).allMatches(value).map((match) => match.group(0)!).toList();
  if (words.isEmpty) {
    return 'value';
  }

  final buffer = StringBuffer(words.first.toLowerCase());
  for (final word in words.skip(1)) {
    buffer.write(_pascal(word));
  }

  final normalized = buffer.toString();
  if (RegExp(r'^[0-9]').hasMatch(normalized)) {
    return 'v$normalized';
  }
  return normalized;
}

String _inputObjectDefinition(_ClientInputObjectType input) {
  final constructorParameters = input.fields
      .map(
        (field) => field.required
            ? 'required this.${field.name}'
            : 'this.${field.name}',
      )
      .join(', ');
  final fields = input.fields
      .map(
        (field) =>
            '  final ${field.type.typeAnnotation(optional: !field.required)} ${field.name};',
      )
      .join('\n');
  final jsonEntries = input.fields.map(_inputFieldJsonEntry).join('\n');
  final fromJsonArguments = input.fields
      .map(_inputFieldFromJsonArgument)
      .join('\n');
  final body = <String>[
    'class ${input.className} {',
    '  const ${input.className}({$constructorParameters});',
    '',
    '  factory ${input.className}.fromJson(Map<String, Object?> json) {',
    '    return ${input.className}(',
    if (fromJsonArguments.isNotEmpty) fromJsonArguments,
    '    );',
    '  }',
    if (fields.isNotEmpty) '',
    if (fields.isNotEmpty) fields,
    '',
    '  Map<String, Object?> toJson() {',
    '    return {',
    if (jsonEntries.isNotEmpty) jsonEntries,
    '    };',
    '  }',
    '}',
  ];
  return body.join('\n');
}

String _modelFilePath(String className) {
  return 'models/${_typeFileName(className)}.dart';
}

String _typeFileName(String className) {
  final withUnderscores = className
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)}',
      )
      .replaceAllMapped(
        RegExp(r'([A-Z]+)([A-Z][a-z])'),
        (match) => '${match.group(1)}_${match.group(2)}',
      );
  return withUnderscores.toLowerCase();
}

String _inputFieldJsonEntry(_ClientInputField field) {
  final key = _dartString(field.jsonName);
  if (!field.required) {
    return '''
      if (${field.name} case final value?) $key: ${field.type.encodeExpression('value')},''';
  }
  if (field.type.nullable) {
    return '''
      $key: switch (${field.name}) {
        null => null,
        final value => ${field.type.encodeExpression('value')},
      },''';
  }
  return "      $key: ${field.type.encodeExpression(field.name)},";
}

String _inputFieldFromJsonArgument(_ClientInputField field) {
  final source = "json[${_dartString(field.jsonName)}]";
  if (!field.required) {
    return '''
        ${field.name}: switch ($source) {
          null => null,
          final value => ${field.type.decodeExpression('value')},
        },''';
  }
  return "        ${field.name}: ${field.type.decodeExpression(source)},";
}

_ClientRootRoutes _buildClientRoutes(ScanState state, String routesRootDir) {
  final root = _ClientRootRoutes();

  for (final route in state.routes) {
    final segments = _routeSegments(route.path);
    final sourceFileSegments = _sourceRouteFileSegments(route, routesRootDir);
    if (segments.isEmpty) {
      final node = root.root ??= _ClientRouteNode(
        parent: null,
        propertyName: 'root',
        classStem: ['Root'],
        fileSegments: const ['index'],
        pathParamNames: const [],
        pathParams: const [],
        routePath: '/',
      );
      node.routes.add(route);
      node.fileSegments = sourceFileSegments;
      continue;
    }

    var children = root.childrenByKey;
    var classStem = <String>[];
    var pathParamNames = <String>[];
    var pathParams = <_ClientParam>[];
    _ClientRouteNode? node;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      final names = _segmentParamNames(
        segment,
        wildcardParam: index == segments.length - 1
            ? route.wildcardParam
            : null,
      );
      final params = _segmentParams(
        segment,
        wildcardParam: index == segments.length - 1
            ? route.wildcardParam
            : null,
      );
      final isDynamic = names.isNotEmpty || segment.contains(':');
      final propertyName = isDynamic
          ? _dynamicPropertyName(names)
          : _literalPropertyName(segment);
      final key = '${isDynamic ? 'dynamic' : 'literal'}:$propertyName';
      final nextParams = [...pathParamNames];
      for (final name in names) {
        if (!nextParams.contains(name)) {
          nextParams.add(name);
        }
      }
      final nextClientParams = [...pathParams];
      for (final param in params) {
        final usedNames = nextClientParams.map((it) => it.name).toSet();
        final uniqueName = _uniqueParamName(param.name, usedNames);
        nextClientParams.add(param.copyWith(name: uniqueName));
      }

      node = children.putIfAbsent(
        key,
        () => _ClientRouteNode(
          parent: node,
          propertyName: propertyName,
          classStem: [...classStem, _pascal(propertyName)],
          fileSegments: _defaultNodeFileSegmentsForRoute(
            sourceFileSegments,
            index,
          ),
          pathParamNames: nextParams,
          pathParams: nextClientParams,
          routePath: '/${segments.take(index + 1).join('/')}',
        ),
      );
      children = node.childrenByKey;
      classStem = node.classStem;
      pathParamNames = node.pathParamNames;
      pathParams = node.pathParams;
    }

    node!.routes.add(route);
    node.fileSegments = sourceFileSegments;
  }

  return root;
}

bool _ownsParams(_ClientRouteNode node) {
  return node.routes.isNotEmpty && identical(_paramsOwner(node), node);
}

_ClientRouteNode? _paramsOwner(_ClientRouteNode node) {
  if (node.pathParams.isEmpty) {
    return null;
  }

  var current = node.parent;
  while (current != null) {
    if (_samePathParams(current.pathParams, node.pathParams) &&
        _ownsParams(current)) {
      return current;
    }
    current = current.parent;
  }

  return node.routes.isNotEmpty ? node : null;
}

_ClientRouteNode? _paramsBaseNode(_ClientRouteNode node) {
  if (!_ownsParams(node)) {
    return null;
  }

  var current = node.parent;
  while (current != null) {
    if (_ownsParams(current)) {
      return current;
    }
    current = current.parent;
  }

  return null;
}

List<_ClientParam> _ownPathParams(_ClientRouteNode node) {
  final base = _paramsBaseNode(node);
  if (base == null) {
    return node.pathParams;
  }
  return node.pathParams.skip(base.pathParams.length).toList();
}

bool _samePathParams(List<_ClientParam> a, List<_ClientParam> b) {
  if (a.length != b.length) {
    return false;
  }

  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

List<String> _routeSegments(String path) => switch (path) {
  '/' => const [],
  _ => path.substring(1).split('/'),
};

List<String> _segmentParamNames(String segment, {String? wildcardParam}) {
  final names = RegExp(
    r':([A-Za-z_][A-Za-z0-9_]*)',
  ).allMatches(segment).map((match) => match.group(1)!).toList();
  if (names.isNotEmpty) {
    return names;
  }
  if (wildcardParam != null && wildcardParam.isNotEmpty) {
    return [wildcardParam];
  }
  return const [];
}

List<_ClientParam> _segmentParams(String segment, {String? wildcardParam}) {
  if (wildcardParam != null && wildcardParam.isNotEmpty) {
    return [
      const _ClientParam(
        name: 'slug',
        type: 'List<String>',
        defaultValue: 'const []',
      ).copyWith(name: wildcardParam),
    ];
  }
  if (segment == '**') {
    return const [
      _ClientParam(
        name: 'segments',
        type: 'List<String>',
        defaultValue: 'const []',
      ),
    ];
  }
  if (segment == '*') {
    return const [
      _ClientParam(name: 'segment', type: 'String', required: true),
    ];
  }

  return RegExp(
    r':([A-Za-z_][A-Za-z0-9_]*)(?:\(([^)]*)\))?([?+*])?',
  ).allMatches(segment).map((match) {
    final name = match.group(1)!;
    final pattern = match.group(2);
    final suffix = match.group(3);
    return switch (suffix) {
      '?' => _ClientParam(name: name, type: 'String?', regexPattern: pattern),
      '+' => _ClientParam(
        name: name,
        type: 'List<String>',
        required: true,
        regexPattern: pattern,
        requiresAtLeastOne: true,
      ),
      '*' => _ClientParam(
        name: name,
        type: 'List<String>',
        defaultValue: 'const []',
        regexPattern: pattern,
      ),
      _ => _ClientParam(
        name: name,
        type: 'String',
        required: true,
        regexPattern: pattern,
      ),
    };
  }).toList();
}

String _uniqueParamName(String baseName, Set<String> usedNames) {
  if (!usedNames.contains(baseName)) {
    return baseName;
  }

  var index = 2;
  while (usedNames.contains('$baseName$index')) {
    index++;
  }
  return '$baseName$index';
}

String _dynamicPropertyName(List<String> names) {
  if (names.isEmpty) {
    return 'byPath';
  }
  return 'by${names.map(_pascal).join('And')}';
}

String _literalPropertyName(String segment) {
  final words = RegExp(
    r'[A-Za-z0-9]+',
  ).allMatches(segment).map((match) => match.group(0)!).toList();
  if (words.isEmpty) {
    return 'segment';
  }

  final buffer = StringBuffer(words.first.toLowerCase());
  for (final word in words.skip(1)) {
    buffer.write(_pascal(word));
  }

  final normalized = buffer.toString();
  if (RegExp(r'^[0-9]').hasMatch(normalized)) {
    return 's$normalized';
  }
  return normalized;
}

String _pascal(String value) {
  if (value.isEmpty) {
    return value;
  }
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

final class _ClientRootRoutes {
  _ClientRouteNode? root;
  final Map<String, _ClientRouteNode> childrenByKey = {};

  Iterable<_ClientRouteNode> get children {
    final values = childrenByKey.values.toList()
      ..sort((a, b) => a.propertyName.compareTo(b.propertyName));
    return values;
  }
}

final class _ClientRouteNode {
  _ClientRouteNode({
    required this.parent,
    required this.propertyName,
    required this.classStem,
    required this.fileSegments,
    required this.pathParamNames,
    required this.pathParams,
    required this.routePath,
  });

  final _ClientRouteNode? parent;
  final String propertyName;
  final List<String> classStem;
  List<String> fileSegments;
  final List<String> pathParamNames;
  final List<_ClientParam> pathParams;
  final String routePath;
  final Map<String, _ClientRouteNode> childrenByKey = {};
  final List<RouteEntry> routes = [];

  String get className => '${classStem.join()}Routes';
  String get filePath => 'routes/${fileSegments.join('/')}.dart';
  String get paramsFilePath => 'params/${fileSegments.join('/')}.dart';

  Iterable<_ClientRouteNode> get children {
    final values = childrenByKey.values.toList()
      ..sort((a, b) => a.propertyName.compareTo(b.propertyName));
    return values;
  }
}

final class _ClientTypedDataRef {
  const _ClientTypedDataRef({required this.filePath, required this.typeName});

  final String filePath;
  final String typeName;
}

final class _ClientTypedDataResult {
  const _ClientTypedDataResult({required this.reference, this.inputFile});

  final _ClientTypedDataRef reference;
  final _ClientInputFile? inputFile;
}

final class _ClientTypedDataBuildResult {
  const _ClientTypedDataBuildResult({
    required this.routeDataTypes,
    required this.inputFiles,
  });

  final Map<RouteEntry, _ClientTypedDataRef> routeDataTypes;
  final Map<String, _ClientInputFile> inputFiles;
}

final class _ClientInputFile extends _ClientTypedDataRef {
  const _ClientInputFile({
    required super.filePath,
    required super.typeName,
    required this.source,
  });

  final String source;
}

final class _ClientModelFile extends _ClientTypedDataRef {
  const _ClientModelFile({
    required super.filePath,
    required super.typeName,
    required this.source,
  });

  final String source;
}

final class _ClientInputParseContext {
  _ClientInputParseContext({
    this.components = const {},
    this.models,
    Map<String, _ClientInputObjectType>? objectTypesByShape,
  }) : objectTypesByShape = objectTypesByShape ?? {};

  final Map<String, Object?> components;
  final _ClientModelRegistry? models;
  final Map<String, _ClientInputObjectType> objectTypesByShape;
}

final class _ClientModelRegistry {
  final Map<String, _ClientModelFile> filesByName = {};
  final Map<String, _ClientInputObjectType> objectTypesByName = {};
  final Map<String, _ClientInputObjectType> objectTypesByShape = {};
  final Set<String> _resolving = {};

  void registerComponents(Map<String, Object?> components) {
    if (components['schemas'] case final Map<String, Object?> schemas) {
      final names = schemas.keys.whereType<String>().toList()..sort();
      for (final name in names) {
        resolveSchema(name, components);
      }
    }
  }

  _ClientInputObjectType? resolveSchema(
    String name,
    Map<String, Object?> components,
  ) {
    if (objectTypesByName[name] case final model?) {
      return model;
    }
    if (!_resolving.add(name)) {
      return null;
    }

    try {
      final schema = _resolveComponentRef(
        '#/components/schemas/$name',
        components: components,
      );
      if (schema is! Map<String, Object?>) {
        return null;
      }

      final parsed = _parseClientInputType(
        schema,
        className: name,
        context: _ClientInputParseContext(
          components: components,
          models: this,
          objectTypesByShape: {},
        ),
      );
      if (parsed is! _ClientInputObjectType) {
        return null;
      }

      final model = parsed.copyWith(
        className: name,
        nullable: false,
        isModel: true,
        filePath: _modelFilePath(name),
      );
      if (objectTypesByName[name] case final existing?) {
        if (existing.definitionKey != model.definitionKey) {
          throw StateError(
            'Conflicting client model schema for component `$name`.',
          );
        }
        return existing;
      }

      objectTypesByName[name] = model;
      objectTypesByShape.putIfAbsent(model.definitionKey, () => model);
      filesByName[name] = _ClientModelFile(
        filePath: model.filePath!,
        typeName: name,
        source: _modelEntry(model),
      );
      return model;
    } finally {
      _resolving.remove(name);
    }
  }
}

final class _SchemaTypeInfo {
  const _SchemaTypeInfo(this.type, this.nullable);

  final String type;
  final bool nullable;
}

String _paramsClassName(_ClientRouteNode node) {
  return '${node.classStem.join()}Params';
}

sealed class _ClientInputType {
  const _ClientInputType({this.nullable = false});

  final bool nullable;

  String get baseType;

  String typeAnnotation({bool optional = false}) {
    return optional || nullable ? '$baseType?' : baseType;
  }

  String encodeExpression(String expression);

  String decodeExpression(String expression);

  String get structuralSignature;

  Iterable<_ClientInputObjectType> get objectTypes;
}

final class _ClientInputScalarType extends _ClientInputType {
  const _ClientInputScalarType({
    required this.dartType,
    required super.nullable,
    this.isDateTime = false,
  });

  final String dartType;
  final bool isDateTime;

  @override
  String get baseType => dartType;

  @override
  String encodeExpression(String expression) {
    if (isDateTime) {
      return '$expression.toIso8601String()';
    }
    return expression;
  }

  @override
  String decodeExpression(String expression) {
    final decoded = switch (dartType) {
      'DateTime' => 'DateTime.parse($expression as String)',
      'double' => '($expression as num).toDouble()',
      _ => '$expression as $dartType',
    };
    if (!nullable) {
      return decoded;
    }
    return 'switch ($expression) { null => null, final value => ${switch (dartType) {
      'DateTime' => 'DateTime.parse(value as String)',
      'double' => '(value as num).toDouble()',
      _ => 'value as $dartType',
    }} }';
  }

  @override
  String get structuralSignature =>
      'scalar:$dartType:${nullable ? 'nullable' : 'required'}';

  @override
  Iterable<_ClientInputObjectType> get objectTypes => const [];
}

final class _ClientInputListType extends _ClientInputType {
  const _ClientInputListType({required this.itemType, required super.nullable});

  final _ClientInputType itemType;

  @override
  String get baseType => 'List<${itemType.typeAnnotation()}>';

  @override
  String encodeExpression(String expression) {
    return '$expression.map((item) => ${itemType.encodeExpression('item')}).toList(growable: false)';
  }

  @override
  String decodeExpression(String expression) {
    final decoded =
        '($expression as List<Object?>).map((item) => ${itemType.decodeExpression('item')}).toList(growable: false)';
    if (!nullable) {
      return decoded;
    }
    return 'switch ($expression) { null => null, final value => (value as List<Object?>).map((item) => ${itemType.decodeExpression('item')}).toList(growable: false) }';
  }

  @override
  String get structuralSignature =>
      'list:${itemType.structuralSignature}:${nullable ? 'nullable' : 'required'}';

  @override
  Iterable<_ClientInputObjectType> get objectTypes => itemType.objectTypes;
}

final class _ClientInputObjectType extends _ClientInputType {
  const _ClientInputObjectType({
    required this.className,
    required this.fields,
    required this.isModel,
    required super.nullable,
    this.filePath,
  });

  final String className;
  final List<_ClientInputField> fields;
  final bool isModel;
  final String? filePath;

  @override
  String get baseType => className;

  @override
  String encodeExpression(String expression) {
    return '$expression.toJson()';
  }

  @override
  String decodeExpression(String expression) {
    final decoded = '$className.fromJson($expression as Map<String, Object?>)';
    if (!nullable) {
      return decoded;
    }
    return 'switch ($expression) { null => null, final value => $className.fromJson(value as Map<String, Object?>) }';
  }

  String get definitionKey =>
      'object:${fields.map((field) => field.structuralSignature).join('|')}';

  @override
  String get structuralSignature =>
      '$definitionKey:${nullable ? 'nullable' : 'required'}';

  _ClientInputObjectType copyWith({
    String? className,
    bool? nullable,
    List<_ClientInputField>? fields,
    bool? isModel,
    String? filePath,
  }) {
    return _ClientInputObjectType(
      className: className ?? this.className,
      fields: fields ?? this.fields,
      isModel: isModel ?? this.isModel,
      nullable: nullable ?? this.nullable,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  Iterable<_ClientInputObjectType> get objectTypes sync* {
    for (final field in fields) {
      yield* field.type.objectTypes;
    }
    yield this;
  }
}

final class _ClientInputField {
  const _ClientInputField({
    required this.name,
    required this.jsonName,
    required this.type,
    required this.required,
  });

  final String name;
  final String jsonName;
  final _ClientInputType type;
  final bool required;

  String get structuralSignature =>
      '$jsonName:${required ? 'required' : 'optional'}:${type.structuralSignature}';
}

final class _ClientParam {
  const _ClientParam({
    required this.name,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.regexPattern,
    this.requiresAtLeastOne = false,
  });

  final String name;
  final String type;
  final bool required;
  final String? defaultValue;
  final String? regexPattern;
  final bool requiresAtLeastOne;

  bool get hasValidation => regexPattern != null || requiresAtLeastOne;
  bool get isList => type.startsWith('List<');
  bool get isNullable => type.endsWith('?');

  String get constructorParameter => switch ((required, defaultValue)) {
    (true, _) => 'required this.$name',
    (_, final defaultValue?) => 'this.$name = $defaultValue',
    _ => 'this.$name',
  };

  String get superConstructorParameter => switch ((required, defaultValue)) {
    (true, _) => 'required super.$name',
    (_, final defaultValue?) => 'super.$name = $defaultValue',
    _ => 'super.$name',
  };

  String get validatingConstructorParameter =>
      switch ((required, defaultValue)) {
        (true, _) => 'required $type $name',
        (_, final defaultValue?) => '$type $name = $defaultValue',
        _ => '$type $name',
      };

  String get initializerExpression => switch (hasValidation) {
    true => '_validate${_pascal(name)}($name)',
    false => name,
  };

  _ClientParam copyWith({
    String? name,
    String? type,
    bool? required,
    String? defaultValue,
    String? regexPattern,
    bool? requiresAtLeastOne,
  }) {
    return _ClientParam(
      name: name ?? this.name,
      type: type ?? this.type,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
      regexPattern: regexPattern ?? this.regexPattern,
      requiresAtLeastOne: requiresAtLeastOne ?? this.requiresAtLeastOne,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _ClientParam &&
        other.name == name &&
        other.type == type &&
        other.required == required &&
        other.defaultValue == defaultValue &&
        other.regexPattern == regexPattern &&
        other.requiresAtLeastOne == requiresAtLeastOne;
  }

  @override
  int get hashCode => Object.hash(
    name,
    type,
    required,
    defaultValue,
    regexPattern,
    requiresAtLeastOne,
  );
}

String _relativeRouteImport(String fromFile, String toFile) {
  final relative = p.posix.relative(toFile, from: p.posix.dirname(fromFile));
  return relative;
}

List<String> _defaultNodeFileSegmentsForRoute(
  List<String> sourceFileSegments,
  int segmentIndex,
) {
  final hasTrailingIndex =
      sourceFileSegments.isNotEmpty && sourceFileSegments.last == 'index';
  final maxPrefixLength = hasTrailingIndex
      ? sourceFileSegments.length - 1
      : sourceFileSegments.length;
  final prefixLength = (segmentIndex + 1).clamp(0, maxPrefixLength);
  return [...sourceFileSegments.take(prefixLength), 'index'];
}

List<String> _sourceOperationFileSegments(
  RouteEntry route,
  String routesRootDir,
) {
  final relative = p.relative(route.filePath, from: routesRootDir);
  final segments = p.split(relative);
  final fileName = segments.last;
  return [...segments.take(segments.length - 1), p.withoutExtension(fileName)];
}

List<String> _sourceRouteFileSegments(RouteEntry route, String routesRootDir) {
  final relative = p.relative(route.filePath, from: routesRootDir);
  final segments = p.split(relative);
  final fileName = segments.last;
  final withoutExtension = p.withoutExtension(fileName);
  final stem = switch (route.method) {
    null => withoutExtension,
    final method when withoutExtension.endsWith('.${method.name}') =>
      withoutExtension.substring(
        0,
        withoutExtension.length - method.name.length - 1,
      ),
    _ => withoutExtension,
  };
  return [...segments.take(segments.length - 1), stem];
}

String _dartHeadersLiteral(Headers headers) {
  final grouped = <String, List<String>>{};
  for (final MapEntry(:key, :value) in headers.entries()) {
    (grouped[key] ??= <String>[]).add(value);
  }

  final entries = grouped.entries.map((entry) {
    final value = switch (entry.value) {
      [final single] => _dartString(single),
      final values => '[${values.map(_dartString).join(', ')}]',
    };
    return '${_dartString(entry.key)}: $value';
  });

  return '{${entries.join(', ')}}';
}

String _dartString(String value) {
  return "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$').replaceAll('\n', r'\n').replaceAll('\r', r'\r').replaceAll('\t', r'\t')}'";
}
