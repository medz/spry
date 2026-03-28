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
      '  /// Creates a generated client shell.\n  const SpryClient({required super.endpoint, super.headers});',
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
    "import 'dart:async';",
    "import 'package:spry/client.dart';",
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
      ..add(_callMethodDefinition(node.routes.single, node.pathParamNames));
  } else {
    for (final route in node.routes) {
      members
        ..add('')
        ..add(_routeMethodDefinition(route, node.pathParamNames));
    }
  }

  return '''// Generated by `spry build client`.
// ignore_for_file: public_member_api_docs, file_names

$imports

class ${node.className} extends ClientRoutes {
${members.join('\n')}
}''';
}

String _routeMethodDefinition(RouteEntry route, List<String> pathParamNames) {
  final methodName = route.method?.name ?? 'call';
  final parameters = switch (pathParamNames) {
    [] => '',
    _ =>
      '{${pathParamNames.map((name) => 'required String $name').join(', ')}}',
  };
  return '  Future<Object?> $methodName($parameters) => throw UnimplementedError();';
}

String _callMethodDefinition(RouteEntry route, List<String> pathParamNames) {
  final parameters = switch (pathParamNames) {
    [] => '',
    _ =>
      '{${pathParamNames.map((name) => 'required String $name').join(', ')}}',
  };
  return '  Future<Object?> call($parameters) => throw UnimplementedError();';
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
        routePath: '/',
      );
      node.routes.add(route);
      node.fileSegments = _sourceRouteFileSegments(route, routesRootDir);
      continue;
    }

    var children = root.childrenByKey;
    var classStem = <String>[];
    var pathParamNames = <String>[];
    _ClientRouteNode? node;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      final names = _segmentParamNames(
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

      node = children.putIfAbsent(
        key,
        () => _ClientRouteNode(
          propertyName: propertyName,
          classStem: [...classStem, _pascal(propertyName)],
          fileSegments: _defaultNodeFileSegments(segments.take(index + 1)),
          pathParamNames: nextParams,
          routePath: '/${segments.take(index + 1).join('/')}',
        ),
      );
      children = node.childrenByKey;
      classStem = node.classStem;
      pathParamNames = node.pathParamNames;
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
    required this.routePath,
  });

  final String propertyName;
  final List<String> classStem;
  List<String> fileSegments;
  final List<String> pathParamNames;
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
