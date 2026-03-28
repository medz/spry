import 'dart:io';
import 'dart:isolate';

import 'package:coal/args.dart';
import 'package:ht/ht.dart' show Headers;
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart'
    show BuildConfig, RouteEntry, RouteTree, scan;
import 'package:spry/config.dart' show ClientConfig;

import 'ansi.dart';
import 'command_support.dart';

Future<int> runBuildClient(
  String cwd,
  Args args,
  StringSink out,
  StringSink err,
) async {
  return runCommand(err, () async {
    final config = await loadCommandConfig(cwd, args);
    final client = config.client ?? ClientConfig();
    final tree = await scan(config);
    final routesRootDir = p.normalize(p.absolute(config.rootDir, 'routes'));
    final pkgDir = _resolveClientPkgDir(config, client);
    final outputDir = _resolveClientOutputDir(pkgDir, client);

    await _ensureClientPubspec(pkgDir);
    await _ensureSpryDependency(pkgDir);
    await _writeClientOutput(outputDir, client, tree, routesRootDir);

    out.writeln(
      '  ${green('✓')}  built client → ${p.relative(pkgDir, from: config.rootDir)}',
    );
    return 0;
  });
}

Future<void> _writeClientOutput(
  String outputDir,
  ClientConfig client,
  RouteTree tree,
  String routesRootDir,
) async {
  final routesDir = Directory(p.join(outputDir, 'routes'));
  if (await routesDir.exists()) {
    await routesDir.delete(recursive: true);
  }

  final routesLibrary = File(p.join(outputDir, 'routes.dart'));
  if (await routesLibrary.exists()) {
    await routesLibrary.delete();
  }

  final files = _clientFiles(client, tree, routesRootDir);
  for (final MapEntry(:key, :value) in files.entries) {
    final file = File(p.joinAll([outputDir, ...key.split('/')]));
    await file.parent.create(recursive: true);
    await file.writeAsString(value);
  }
}

String _resolveClientPkgDir(BuildConfig config, ClientConfig client) {
  return p.normalize(p.absolute(config.rootDir, client.pkgDir));
}

String _resolveClientOutputDir(String pkgDir, ClientConfig client) {
  return p.normalize(p.absolute(pkgDir, client.output));
}

Future<void> _ensureClientPubspec(String pkgDir) async {
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

Future<void> _ensureSpryDependency(String pkgDir) async {
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

Map<String, String> _clientFiles(
  ClientConfig client,
  RouteTree tree,
  String routesRootDir,
) {
  final routes = _buildClientRoutes(tree, routesRootDir);
  return {
    'client.dart': _clientEntry(client, routes),
    'routes.dart': _routesLibrary(routes),
    for (final node in _routeNodes(routes)) node.filePath: _routeEntry(node),
  };
}

String _clientEntry(ClientConfig client, _ClientRootRoutes routes) {
  final imports = [
    "import 'package:spry/client.dart';",
    "import 'routes.dart';",
  ].join('\n');

  final clientBody = [
    _clientConstructor(client),
    ?_clientGlobalHeadersMember(client),
    ..._rootNamespaceMembers(routes),
  ].join('\n');

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$imports

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

String _routeEntry(_ClientRouteNode node) {
  final imports = [
    if (node.routes.isNotEmpty) "import 'dart:async';",
    "import 'package:spry/client.dart';",
    for (final child in node.children)
      "import '${_relativeRouteImport(node.filePath, child.filePath)}';",
  ].join('\n');
  final paramsTypeDefinition = _paramsTypeDefinitions(node);

  final members = <String>['  ${node.className}(super.client);'];

  for (final child in node.children) {
    members
      ..add('')
      ..add('  late final ${child.propertyName} = ${child.className}(client);');
  }

  if (node.routes.length == 1) {
    members
      ..add('')
      ..add(_callMethodDefinition(node.routes.single, node));
  } else {
    for (final route in node.routes) {
      members
        ..add('')
        ..add(_routeMethodDefinition(route, node));
    }
  }

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$imports

${paramsTypeDefinition.isEmpty ? '' : '$paramsTypeDefinition\n'}
class ${node.className} extends ClientRoutes {
${members.join('\n')}
}''';
}

String _routeMethodDefinition(RouteEntry route, _ClientRouteNode node) {
  final methodName = route.method?.name ?? 'call';
  final parameters = _callParameters(node, route);
  return '  Future<Object?> $methodName($parameters) => throw UnimplementedError();';
}

String _callMethodDefinition(RouteEntry route, _ClientRouteNode node) {
  final parameters = _callParameters(node, route);
  return '  Future<Object?> call($parameters) => throw UnimplementedError();';
}

String _paramsTypeDefinitions(_ClientRouteNode node) {
  if (node.pathParams.isEmpty) {
    return '';
  }

  return node.routes
      .map((route) => _paramsTypeDefinition(node, route))
      .join('\n\n');
}

String _paramsTypeDefinition(_ClientRouteNode node, RouteEntry route) {
  final className = _paramsClassName(node, route);
  final fields = node.pathParams
      .map((param) => '  final ${param.type} ${param.name};')
      .join('\n');
  if (!node.pathParams.any((param) => param.hasValidation)) {
    final parameters = node.pathParams
        .map((param) => param.constructorParameter)
        .join(', ');
    return '''class $className {
  const $className({$parameters});

$fields
}
''';
  }

  final parameters = node.pathParams
      .map((param) => param.validatingConstructorParameter)
      .join(', ');
  final initializers = node.pathParams
      .map((param) => '${param.name} = ${param.initializerExpression}')
      .join(',\n        ');
  final validators = node.pathParams
      .where((param) => param.hasValidation)
      .map(_validatorDefinition)
      .join('\n\n');
  return '''class $className {
  $className({$parameters})
      : $initializers;

$fields

$validators
}
''';
}

String _callParameters(_ClientRouteNode node, RouteEntry route) {
  final namedParameters = <String>[
    if (node.pathParams.isNotEmpty) _paramsCallParameter(node, route),
    'Object? data',
    'BodyInit? body',
    'Headers? headers',
    'URLSearchParams? query',
  ];
  return '{${namedParameters.join(', ')}}';
}

String _paramsCallParameter(_ClientRouteNode node, RouteEntry route) {
  final className = _paramsClassName(node, route);
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

_ClientRootRoutes _buildClientRoutes(RouteTree tree, String routesRootDir) {
  final root = _ClientRootRoutes();

  for (final route in tree.routes) {
    final segments = _routeSegments(route.path);
    if (segments.isEmpty) {
      final node = root.root ??= _ClientRouteNode(
        propertyName: 'root',
        classStem: ['Root'],
        fileSegments: const ['index'],
        pathParamNames: const [],
        pathParams: const [],
        routePath: '/',
      );
      node.routes.add(route);
      node.fileSegments = _sourceRouteFileSegments(route, routesRootDir);
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
          propertyName: propertyName,
          classStem: [...classStem, _pascal(propertyName)],
          fileSegments: _defaultNodeFileSegments(segments.take(index + 1)),
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
    node.fileSegments = _sourceRouteFileSegments(route, routesRootDir);
  }

  return root;
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
    required this.propertyName,
    required this.classStem,
    required this.fileSegments,
    required this.pathParamNames,
    required this.pathParams,
    required this.routePath,
  });

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

  Iterable<_ClientRouteNode> get children {
    final values = childrenByKey.values.toList()
      ..sort((a, b) => a.propertyName.compareTo(b.propertyName));
    return values;
  }
}

String _paramsClassName(_ClientRouteNode node, RouteEntry route) {
  final prefix = switch (route.method) {
    null => '',
    final method => _pascal(method.name),
  };
  return '$prefix${node.classStem.join()}Params';
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
}

String _relativeRouteImport(String fromFile, String toFile) {
  final relative = p.posix.relative(toFile, from: p.posix.dirname(fromFile));
  return relative;
}

List<String> _defaultNodeFileSegments(Iterable<String> segments) {
  final values = segments.toList();
  return switch (values) {
    [] => const ['index'],
    _ => [...values, 'index'],
  };
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
