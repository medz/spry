import 'dart:io';

import 'package:path/path.dart' as p;

import 'config.dart';
import 'route_tree.dart';

final class RouteScanException implements Exception {
  const RouteScanException(this.message);

  final String message;

  @override
  String toString() => 'RouteScanException: $message';
}

Future<RouteTree> scan(BuildConfig config) async {
  final root = config.rootDir;
  final routesRoot = Directory(p.join(root, config.routesDir));
  final middlewareRoot = Directory(p.join(root, config.middlewareDir));

  final globalMiddleware = <MiddlewareEntry>[];
  final scopedMiddleware = <MiddlewareEntry>[];
  final scopedErrors = <ErrorEntry>[];
  final routes = <RouteEntry>[];
  RouteEntry? fallback;

  if (await middlewareRoot.exists()) {
    final files = await _collectDartFiles(middlewareRoot, recursive: false);
    files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    for (final file in files) {
      final parsed = _parseScopedHandlerFile(
        p.basename(file.path),
        expectedBaseName: null,
      )!;
      globalMiddleware.add(
        MiddlewareEntry(filePath: file.path, path: '/*', method: parsed.method),
      );
    }
  }

  final seenRoutes = <String, String>{};
  final seenShapes = <String, _ShapeRecord>{};
  final catchAllKindsByDir = <String, bool?>{};

  if (await routesRoot.exists()) {
    final files = await _collectDartFiles(routesRoot, recursive: true);
    files.sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final relativePath = p.relative(file.path, from: routesRoot.path);
      final segments = p.split(relativePath);
      final fileName = segments.last;
      final dirSegments = segments.take(segments.length - 1).toList();

      if (dirSegments.any((segment) => segment.startsWith('_'))) {
        continue;
      }

      final scopedMiddlewareFile = _parseScopedHandlerFile(
        fileName,
        expectedBaseName: '_middleware',
      );
      if (scopedMiddlewareFile != null) {
        scopedMiddleware.add(
          MiddlewareEntry(
            filePath: file.path,
            path: _scopePath(dirSegments),
            method: scopedMiddlewareFile.method,
          ),
        );
        continue;
      }

      final scopedErrorFile = _parseScopedHandlerFile(
        fileName,
        expectedBaseName: '_error',
      );
      if (scopedErrorFile != null) {
        scopedErrors.add(
          ErrorEntry(
            filePath: file.path,
            path: _scopePath(dirSegments),
            method: scopedErrorFile.method,
          ),
        );
        continue;
      }

      if (fileName.startsWith('_')) {
        continue;
      }

      final parsed = _parseRouteFile(relativePath);
      final dirKey = p.dirname(relativePath);
      if (parsed.catchAllKind != null) {
        final previous = catchAllKindsByDir[dirKey];
        if (previous != null && previous != parsed.catchAllKind) {
          throw RouteScanException(
            'Conflicting catch-all files in "$dirKey": both named and unnamed catch-all routes are present.',
          );
        }
        catchAllKindsByDir[dirKey] = parsed.catchAllKind;
      }

      final routeKey = '${parsed.method ?? '*'} ${parsed.path}';
      final previous = seenRoutes[routeKey];
      if (previous != null) {
        throw RouteScanException(
          'Duplicate route "$routeKey" declared by "$previous" and "$relativePath".',
        );
      }
      seenRoutes[routeKey] = relativePath;

      final shapeKey = parsed.shapePath;
      final shapeRecord = seenShapes[shapeKey];
      if (shapeRecord != null &&
          !_sameNames(shapeRecord.names, parsed.paramNames)) {
        throw RouteScanException(
          'Param-name drift for route shape "$shapeKey": "${shapeRecord.source}" and "$relativePath".',
        );
      }
      seenShapes.putIfAbsent(
        shapeKey,
        () => _ShapeRecord(relativePath, parsed.paramNames),
      );

      final entry = RouteEntry(
        filePath: file.path,
        path: parsed.path,
        method: parsed.method,
        wildcardParam: parsed.wildcardParam,
      );

      if (parsed.isRootFallback && fallback == null) {
        fallback = entry;
      } else {
        routes.add(entry);
      }
    }
  }

  final hooksFile = File(p.join(root, 'hooks.dart'));
  return RouteTree(
    routes: routes,
    globalMiddleware: globalMiddleware,
    scopedMiddleware: scopedMiddleware,
    scopedErrors: scopedErrors,
    fallback: fallback,
    hooksPath: await hooksFile.exists() ? hooksFile.path : null,
  );
}

Future<List<File>> _collectDartFiles(
  Directory dir, {
  required bool recursive,
}) async {
  final files = <File>[];
  await for (final entity in dir.list(
    recursive: recursive,
    followLinks: false,
  )) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  return files;
}

String _scopePath(List<String> dirSegments) {
  if (dirSegments.isEmpty) {
    return '/*';
  }

  final normalized = _normalizeSegments(dirSegments);
  if (normalized.hasWildcard) {
    throw RouteScanException(
      'Catch-all directories cannot define scoped middleware or error handlers.',
    );
  }
  return '${normalized.path}/*';
}

_ParsedRoute _parseRouteFile(String relativePath) {
  final segments = p.split(relativePath);
  final fileName = segments.last;
  final stem = fileName.substring(0, fileName.length - '.dart'.length);
  final parts = stem.split('.');
  final methodToken = parts.length > 1 ? _parseMethod(parts.last) : null;
  final routeName = methodToken == null
      ? stem
      : parts.sublist(0, parts.length - 1).join('.');
  final pathSegments = [...segments.take(segments.length - 1), routeName];

  final normalized = _normalizeSegments(pathSegments);
  final isRootFallback =
      segments.length == 1 && normalized.path == '/*' && methodToken == null;

  return _ParsedRoute(
    path: normalized.path,
    shapePath: normalized.shapePath,
    method: methodToken,
    wildcardParam: normalized.wildcardParam,
    paramNames: normalized.paramNames,
    catchAllKind: normalized.catchAllKind,
    isRootFallback: isRootFallback,
  );
}

String? _parseMethod(String segment) {
  return switch (segment.toLowerCase()) {
    'get' => 'GET',
    'post' => 'POST',
    'put' => 'PUT',
    'patch' => 'PATCH',
    'delete' => 'DELETE',
    'head' => 'HEAD',
    'options' => 'OPTIONS',
    _ => null,
  };
}

_ScopedHandlerFile? _parseScopedHandlerFile(
  String fileName, {
  required String? expectedBaseName,
}) {
  if (!fileName.endsWith('.dart')) {
    return null;
  }

  final stem = fileName.substring(0, fileName.length - '.dart'.length);
  final parts = stem.split('.');
  final method = parts.length > 1 ? _parseMethod(parts.last) : null;
  final baseName = method == null
      ? stem
      : parts.sublist(0, parts.length - 1).join('.');

  if (expectedBaseName case final name?) {
    return baseName == name ? _ScopedHandlerFile(method: method) : null;
  }

  return _ScopedHandlerFile(method: method);
}

_NormalizedPath _normalizeSegments(List<String> rawSegments) {
  final pathSegments = <String>[];
  final shapeSegments = <String>[];
  final paramNames = <String>[];
  String? wildcardParam;
  bool? catchAllKind;

  for (var i = 0; i < rawSegments.length; i++) {
    final raw = rawSegments[i];
    if (raw == 'index' && i == rawSegments.length - 1) {
      continue;
    }

    final catchAllMatch = RegExp(r'^\[\.\.\.(.*)\]$').firstMatch(raw);
    if (catchAllMatch != null) {
      if (i != rawSegments.length - 1) {
        throw RouteScanException(
          'Catch-all segment must be terminal: "${rawSegments.join('/')}".',
        );
      }
      final name = catchAllMatch.group(1)!;
      wildcardParam = name.isEmpty ? null : name;
      catchAllKind = name.isNotEmpty;
      pathSegments.add('*');
      shapeSegments.add('*');
      continue;
    }

    final paramMatch = RegExp(r'^\[(.+)\]$').firstMatch(raw);
    if (paramMatch != null) {
      final name = paramMatch.group(1)!;
      paramNames.add(name);
      pathSegments.add(':$name');
      shapeSegments.add(':');
      continue;
    }

    pathSegments.add(raw);
    shapeSegments.add(raw);
  }

  if (pathSegments.isEmpty) {
    return const _NormalizedPath(
      path: '/',
      shapePath: '/',
      paramNames: [],
      wildcardParam: null,
      hasWildcard: false,
      catchAllKind: null,
    );
  }

  return _NormalizedPath(
    path: '/${pathSegments.join('/')}',
    shapePath: '/${shapeSegments.join('/')}',
    paramNames: paramNames,
    wildcardParam: wildcardParam,
    hasWildcard: pathSegments.contains('*'),
    catchAllKind: catchAllKind,
  );
}

bool _sameNames(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

final class _ParsedRoute {
  const _ParsedRoute({
    required this.path,
    required this.shapePath,
    required this.method,
    required this.wildcardParam,
    required this.paramNames,
    required this.catchAllKind,
    required this.isRootFallback,
  });

  final String path;
  final String shapePath;
  final String? method;
  final String? wildcardParam;
  final List<String> paramNames;
  final bool? catchAllKind;
  final bool isRootFallback;
}

final class _NormalizedPath {
  const _NormalizedPath({
    required this.path,
    required this.shapePath,
    required this.paramNames,
    required this.wildcardParam,
    required this.hasWildcard,
    required this.catchAllKind,
  });

  final String path;
  final String shapePath;
  final List<String> paramNames;
  final String? wildcardParam;
  final bool hasWildcard;
  final bool? catchAllKind;
}

final class _ShapeRecord {
  const _ShapeRecord(this.source, this.names);

  final String source;
  final List<String> names;
}

final class _ScopedHandlerFile {
  const _ScopedHandlerFile({required this.method});

  final String? method;
}
