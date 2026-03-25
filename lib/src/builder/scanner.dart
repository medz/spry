import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart' show parseString;
import 'package:analyzer/dart/ast/ast.dart'
    show
        AdjacentStrings,
        BooleanLiteral,
        CompilationUnit,
        DoubleLiteral,
        Expression,
        FunctionDeclaration,
        ImportDirective,
        IntegerLiteral,
        ListLiteral,
        MapLiteralEntry,
        MethodInvocation,
        NamedExpression,
        NullLiteral,
        PrefixedIdentifier,
        SetOrMapLiteral,
        SimpleIdentifier,
        SimpleStringLiteral,
        TopLevelVariableDeclaration;
import 'package:ht/ht.dart' show HttpMethod;
import 'package:path/path.dart' as p;

import 'config.dart';
import 'route_tree.dart';

/// Error thrown when route discovery finds an invalid route layout.
final class RouteScanException implements Exception {
  /// Creates a route scan exception with a human-readable [message].
  const RouteScanException(this.message);

  /// Human-readable error description.
  final String message;

  @override
  String toString() => 'RouteScanException: $message';
}

/// Scans the project filesystem and builds a [RouteTree].
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
        MiddlewareEntry(
          filePath: file.path,
          path: '/**',
          method: parsed.method,
        ),
      );
    }
  }

  final seenRoutes = <String, String>{};
  final seenShapes = <String, _ShapeRecord>{};
  final catchAllKindsByDir = <String, bool?>{};
  final openApiSourceCache = <String, Future<_OpenApiSourceContext>>{};

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
        openapi: await _scanOpenApi(file, openApiSourceCache),
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
    hooks: await hooksFile.exists() ? await _scanHooks(hooksFile) : null,
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

Future<HooksEntry> _scanHooks(File file) async {
  final source = await file.readAsString();
  final unit = parseString(
    content: source,
    path: file.path,
    throwIfDiagnostics: false,
  ).unit;
  final functions = unit.declarations.whereType<FunctionDeclaration>();
  return HooksEntry(
    filePath: file.path,
    hasOnStart: functions.any(
      (function) =>
          function.propertyKeyword == null && function.name.lexeme == 'onStart',
    ),
    hasOnStop: functions.any(
      (function) =>
          function.propertyKeyword == null && function.name.lexeme == 'onStop',
    ),
    hasOnError: functions.any(
      (function) =>
          function.propertyKeyword == null && function.name.lexeme == 'onError',
    ),
  );
}

Future<Map<String, dynamic>?> _scanOpenApi(
  File file,
  Map<String, Future<_OpenApiSourceContext>> sourceCache,
) async {
  final context = await _loadOpenApiSourceContext(file.path, sourceCache);
  if (!context.variables.containsKey('openapi')) {
    return null;
  }
  final evaluator = _OpenApiEvaluator(sourceCache);
  return evaluator.evaluateRouteOpenApi(context, 'openapi');
}

Object? _evaluateJsonLikeExpression(
  Expression expression,
  String filePath,
  _OpenApiEvaluator evaluator,
  _OpenApiSourceContext context,
  Set<String> activeVariables,
) {
  return switch (expression) {
    NullLiteral() => null,
    BooleanLiteral() => expression.value,
    IntegerLiteral() => expression.value,
    DoubleLiteral() => expression.value,
    SimpleStringLiteral() => expression.value,
    AdjacentStrings() =>
      expression.strings
          .map(
            (part) => _evaluateJsonLikeExpression(
              part,
              filePath,
              evaluator,
              context,
              activeVariables,
            ),
          )
          .join(),
    ListLiteral() => _evaluateJsonLikeList(
      expression,
      filePath,
      evaluator,
      context,
      activeVariables,
    ),
    SetOrMapLiteral() => _evaluateJsonLikeMap(
      expression,
      filePath,
      evaluator,
      context,
      activeVariables,
    ),
    MethodInvocation() => evaluator.evaluateValueFactory(
      context,
      expression,
      activeVariables,
    ),
    SimpleIdentifier() => evaluator.evaluateReferencedValue(
      context,
      expression.name,
      activeVariables,
    ),
    PrefixedIdentifier() => evaluator.evaluatePrefixedReferencedValue(
      context,
      expression,
      activeVariables,
    ),
    _ => throw RouteScanException(
      'Top-level `openapi` in "$filePath" only supports JSON-like literals.',
    ),
  };
}

List<Object?> _evaluateJsonLikeList(
  ListLiteral expression,
  String filePath,
  _OpenApiEvaluator evaluator,
  _OpenApiSourceContext context,
  Set<String> activeVariables,
) {
  final result = <Object?>[];
  for (final element in expression.elements) {
    if (element is! Expression) {
      throw RouteScanException(
        'Top-level `openapi` in "$filePath" only supports JSON-like list elements.',
      );
    }
    result.add(
      _evaluateJsonLikeExpression(
        element,
        filePath,
        evaluator,
        context,
        activeVariables,
      ),
    );
  }
  return result;
}

Map<String, dynamic> _evaluateJsonLikeMap(
  SetOrMapLiteral expression,
  String filePath,
  _OpenApiEvaluator evaluator,
  _OpenApiSourceContext context,
  Set<String> activeVariables,
) {
  final result = <String, dynamic>{};
  for (final element in expression.elements) {
    if (element is! MapLiteralEntry) {
      throw RouteScanException(
        'Top-level `openapi` in "$filePath" only supports JSON-like map literals.',
      );
    }
    result[_readJsonLikeMapKey(
      element.key,
      filePath,
    )] = _evaluateJsonLikeExpression(
      element.value,
      filePath,
      evaluator,
      context,
      activeVariables,
    );
  }
  return result;
}

String _readJsonLikeMapKey(Expression expression, String filePath) {
  return switch (expression) {
    SimpleStringLiteral() => expression.value,
    AdjacentStrings() =>
      expression.strings
          .map(
            (part) => switch (part) {
              SimpleStringLiteral() => part.value,
              _ => throw RouteScanException(
                'Top-level `openapi` in "$filePath" only supports string map keys.',
              ),
            },
          )
          .join(),
    _ => throw RouteScanException(
      'Top-level `openapi` in "$filePath" only supports string map keys.',
    ),
  };
}

final class _OpenApiSourceContext {
  _OpenApiSourceContext({
    required this.filePath,
    required this.unit,
    required this.variables,
    required this.unprefixedImports,
    required this.prefixedImports,
  });

  final String filePath;
  final CompilationUnit unit;
  final Map<String, Expression> variables;
  final List<String> unprefixedImports;
  final Map<String, String> prefixedImports;
}

Future<_OpenApiSourceContext> _loadOpenApiSourceContext(
  String filePath,
  Map<String, Future<_OpenApiSourceContext>> cache,
) {
  return cache.putIfAbsent(filePath, () async {
    final source = await File(filePath).readAsString();
    final unit = parseString(
      content: source,
      path: filePath,
      throwIfDiagnostics: false,
    ).unit;

    final variables = <String, Expression>{};
    for (final declaration
        in unit.declarations.whereType<TopLevelVariableDeclaration>()) {
      for (final variable in declaration.variables.variables) {
        final initializer = variable.initializer;
        if (initializer != null) {
          variables[variable.name.lexeme] = initializer;
        }
      }
    }

    final unprefixedImports = <String>[];
    final prefixedImports = <String, String>{};
    for (final directive in unit.directives.whereType<ImportDirective>()) {
      final importedPath = _resolveImportedDartFile(filePath, directive);
      if (importedPath == null) {
        continue;
      }
      final prefix = directive.prefix?.name;
      if (prefix == null) {
        unprefixedImports.add(importedPath);
      } else {
        prefixedImports[prefix] = importedPath;
      }
    }

    return _OpenApiSourceContext(
      filePath: filePath,
      unit: unit,
      variables: variables,
      unprefixedImports: unprefixedImports,
      prefixedImports: prefixedImports,
    );
  });
}

String? _resolveImportedDartFile(
  String fromFilePath,
  ImportDirective directive,
) {
  final uri = directive.uri.stringValue;
  if (uri == null || !uri.endsWith('.dart')) {
    return null;
  }
  if (uri.startsWith('package:')) {
    return null;
  }
  return p.normalize(p.absolute(p.dirname(fromFilePath), uri));
}

final class _OpenApiEvaluator {
  _OpenApiEvaluator(this._sourceCache);

  final Map<String, Future<_OpenApiSourceContext>> _sourceCache;

  Future<Map<String, dynamic>> evaluateRouteOpenApi(
    _OpenApiSourceContext context,
    String variableName,
  ) async {
    final expression = context.variables[variableName];
    if (expression == null) {
      throw RouteScanException(
        'Top-level `openapi` in "${context.filePath}" must have an initializer.',
      );
    }
    final evaluated = await _evaluateRouteOpenApiExpression(
      context,
      expression,
      <String>{},
    );
    return evaluated;
  }

  Future<Map<String, dynamic>> _evaluateRouteOpenApiExpression(
    _OpenApiSourceContext context,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    return switch (expression) {
      MethodInvocation() => await evaluateRouteFactory(
        context,
        expression,
        activeVariables,
      ),
      SimpleIdentifier() => await _evaluateVariableReference(
        context,
        expression.name,
        activeVariables,
      ),
      PrefixedIdentifier() => await _evaluatePrefixedVariableReference(
        context,
        expression,
        activeVariables,
      ),
      _ => throw RouteScanException(
        'Top-level `openapi` in "${context.filePath}" must use OpenAPI(...) or reference another top-level OpenAPI value.',
      ),
    };
  }

  Future<Map<String, dynamic>> evaluateRouteFactory(
    _OpenApiSourceContext context,
    MethodInvocation expression,
    Set<String> activeVariables,
  ) async {
    if (expression.target != null) {
      throw RouteScanException(
        'Top-level `openapi` in "${context.filePath}" must use an unprefixed OpenAPI(...) call.',
      );
    }
    final typeName = expression.methodName.name;
    return switch (typeName) {
      'OpenAPI' => await _evaluateOpenApiFactory(
        context,
        expression,
        activeVariables,
      ),
      _ => throw RouteScanException(
        'Top-level `openapi` in "${context.filePath}" must use OpenAPI(...), got `$typeName`.',
      ),
    };
  }

  Future<Object?> evaluateReferencedValue(
    _OpenApiSourceContext context,
    String variableName,
    Set<String> activeVariables,
  ) async {
    return _evaluateVariableValue(context, variableName, activeVariables);
  }

  Future<Object?> evaluatePrefixedReferencedValue(
    _OpenApiSourceContext context,
    PrefixedIdentifier identifier,
    Set<String> activeVariables,
  ) async {
    return _evaluatePrefixedVariableValue(context, identifier, activeVariables);
  }

  Future<Object?> evaluateValueFactory(
    _OpenApiSourceContext context,
    MethodInvocation expression,
    Set<String> activeVariables,
  ) async {
    if (expression.target != null) {
      throw RouteScanException(
        'Unsupported qualified OpenAPI call `${expression.toSource()}` in "${context.filePath}".',
      );
    }
    final typeName = expression.methodName.name;
    return switch (typeName) {
      'OpenAPIComponents' => await _evaluateOpenApiComponentsFactory(
        context,
        expression,
        activeVariables,
      ),
      'OpenAPI' => await _evaluateOpenApiFactory(
        context,
        expression,
        activeVariables,
      ),
      _ => throw RouteScanException(
        'Unsupported OpenAPI constructor `$typeName` in "${context.filePath}".',
      ),
    };
  }

  Future<Map<String, dynamic>> _evaluateOpenApiFactory(
    _OpenApiSourceContext context,
    MethodInvocation expression,
    Set<String> activeVariables,
  ) async {
    final result = <String, dynamic>{};
    for (final argument in expression.argumentList.arguments) {
      if (argument is! NamedExpression) {
        throw RouteScanException(
          'OpenAPI(...) in "${context.filePath}" only supports named arguments.',
        );
      }
      final name = argument.name.label.name;
      final value = await _evaluateValueExpression(
        context,
        argument.expression,
        activeVariables,
      );
      if (name == 'extensions') {
        if (value is! Map) {
          throw RouteScanException(
            'OpenAPI.extensions in "${context.filePath}" must be a map.',
          );
        }
        for (final entry in value.entries) {
          result['x-${entry.key}'] = entry.value;
        }
        continue;
      }
      if (name == 'globalComponents') {
        if (value != null) {
          result['x-spry-openapi-global-components'] = value;
        }
        continue;
      }
      if (value != null) {
        result[name] = value;
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _evaluateOpenApiComponentsFactory(
    _OpenApiSourceContext context,
    MethodInvocation expression,
    Set<String> activeVariables,
  ) async {
    final result = <String, dynamic>{};
    for (final argument in expression.argumentList.arguments) {
      if (argument is! NamedExpression) {
        throw RouteScanException(
          'OpenAPIComponents(...) in "${context.filePath}" only supports named arguments.',
        );
      }
      final value = await _evaluateValueExpression(
        context,
        argument.expression,
        activeVariables,
      );
      if (value != null) {
        result[argument.name.label.name] = value;
      }
    }
    return result;
  }

  Future<Object?> _evaluateValueExpression(
    _OpenApiSourceContext context,
    Expression expression,
    Set<String> activeVariables,
  ) async {
    return switch (expression) {
      MethodInvocation() => await evaluateValueFactory(
        context,
        expression,
        activeVariables,
      ),
      SimpleIdentifier() => await _evaluateVariableValue(
        context,
        expression.name,
        activeVariables,
      ),
      PrefixedIdentifier() => await _evaluatePrefixedVariableValue(
        context,
        expression,
        activeVariables,
      ),
      _ => _evaluateJsonLikeExpression(
        expression,
        context.filePath,
        this,
        context,
        activeVariables,
      ),
    };
  }

  Future<Map<String, dynamic>> _evaluateVariableReference(
    _OpenApiSourceContext context,
    String variableName,
    Set<String> activeVariables,
  ) async {
    final key = '${context.filePath}::$variableName';
    if (!activeVariables.add(key)) {
      throw RouteScanException(
        'Circular OpenAPI variable reference detected at `$key`.',
      );
    }
    try {
      final expression = context.variables[variableName];
      if (expression != null) {
        return _evaluateRouteOpenApiExpression(
          context,
          expression,
          activeVariables,
        );
      }

      final matches = <Map<String, dynamic>>[];
      for (final importPath in context.unprefixedImports) {
        final imported = await _loadOpenApiSourceContext(
          importPath,
          _sourceCache,
        );
        if (!imported.variables.containsKey(variableName)) {
          continue;
        }
        matches.add(
          await _evaluateVariableReference(
            imported,
            variableName,
            activeVariables,
          ),
        );
      }

      if (matches.length == 1) {
        return matches.single;
      }
      if (matches.length > 1) {
        throw RouteScanException(
          'Ambiguous OpenAPI variable `$variableName` imported into "${context.filePath}".',
        );
      }
    } finally {
      activeVariables.remove(key);
    }

    throw RouteScanException(
      'Unknown OpenAPI variable `$variableName` in "${context.filePath}".',
    );
  }

  Future<Map<String, dynamic>> _evaluatePrefixedVariableReference(
    _OpenApiSourceContext context,
    PrefixedIdentifier identifier,
    Set<String> activeVariables,
  ) async {
    final importPath = context.prefixedImports[identifier.prefix.name];
    if (importPath == null) {
      throw RouteScanException(
        'Unknown OpenAPI import prefix `${identifier.prefix.name}` in "${context.filePath}".',
      );
    }
    final imported = await _loadOpenApiSourceContext(importPath, _sourceCache);
    return _evaluateVariableReference(
      imported,
      identifier.identifier.name,
      activeVariables,
    );
  }

  Future<Object?> _evaluateVariableValue(
    _OpenApiSourceContext context,
    String variableName,
    Set<String> activeVariables,
  ) async {
    final key = '${context.filePath}::$variableName';
    if (!activeVariables.add(key)) {
      throw RouteScanException(
        'Circular OpenAPI variable reference detected at `$key`.',
      );
    }
    try {
      final expression = context.variables[variableName];
      if (expression != null) {
        return _evaluateValueExpression(context, expression, activeVariables);
      }

      Object? match;
      for (final importPath in context.unprefixedImports) {
        final imported = await _loadOpenApiSourceContext(
          importPath,
          _sourceCache,
        );
        if (!imported.variables.containsKey(variableName)) {
          continue;
        }
        final value = await _evaluateVariableValue(
          imported,
          variableName,
          activeVariables,
        );
        if (match != null) {
          throw RouteScanException(
            'Ambiguous OpenAPI variable `$variableName` imported into "${context.filePath}".',
          );
        }
        match = value;
      }
      if (match != null) {
        return match;
      }
    } finally {
      activeVariables.remove(key);
    }

    throw RouteScanException(
      'Unknown OpenAPI variable `$variableName` in "${context.filePath}".',
    );
  }

  Future<Object?> _evaluatePrefixedVariableValue(
    _OpenApiSourceContext context,
    PrefixedIdentifier identifier,
    Set<String> activeVariables,
  ) async {
    final importPath = context.prefixedImports[identifier.prefix.name];
    if (importPath == null) {
      throw RouteScanException(
        'Unknown OpenAPI import prefix `${identifier.prefix.name}` in "${context.filePath}".',
      );
    }
    final imported = await _loadOpenApiSourceContext(importPath, _sourceCache);
    return _evaluateVariableValue(
      imported,
      identifier.identifier.name,
      activeVariables,
    );
  }
}

String _scopePath(List<String> dirSegments) {
  if (dirSegments.isEmpty) {
    return '/**';
  }

  final normalized = _normalizeSegments(dirSegments, stripTerminalIndex: false);
  if (normalized.hasRemainderWildcard) {
    throw RouteScanException(
      'Catch-all directories cannot define scoped middleware or error handlers.',
    );
  }
  return '${normalized.path}/**';
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
      segments.length == 1 &&
      normalized.isTerminalRemainderWildcard &&
      methodToken == null;

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

HttpMethod? _parseMethod(String segment) {
  return switch (segment.toLowerCase()) {
    'get' => HttpMethod.get,
    'post' => HttpMethod.post,
    'put' => HttpMethod.put,
    'patch' => HttpMethod.patch,
    'delete' => HttpMethod.delete,
    'head' => HttpMethod.head,
    'options' => HttpMethod.options,
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

_NormalizedPath _normalizeSegments(
  List<String> rawSegments, {
  bool stripTerminalIndex = true,
}) {
  final segments =
      stripTerminalIndex &&
          rawSegments.isNotEmpty &&
          rawSegments.last == 'index'
      ? rawSegments.sublist(0, rawSegments.length - 1)
      : rawSegments;
  final pathSegments = <String>[];
  final shapeSegments = <String>[];
  final paramNames = <String>[];
  final seenParamNames = <String>{};
  String? wildcardParam;
  bool? catchAllKind;
  var hasRemainderWildcard = false;
  var isTerminalRemainderWildcard = false;

  for (var i = 0; i < segments.length; i++) {
    final raw = segments[i];
    final parsed = _parseSegment(
      raw,
      isTerminal: i == segments.length - 1,
      routeShape: segments.join('/'),
    );
    pathSegments.add(parsed.path);
    shapeSegments.add(parsed.shape);
    for (final name in parsed.paramNames) {
      if (!seenParamNames.add(name)) {
        throw RouteScanException(
          'Duplicate param name "$name" in route "${segments.join('/')}".',
        );
      }
      paramNames.add(name);
    }
    wildcardParam ??= parsed.wildcardParam;
    catchAllKind ??= parsed.catchAllKind;
    hasRemainderWildcard = hasRemainderWildcard || parsed.isRemainderWildcard;
    if (i == segments.length - 1) {
      isTerminalRemainderWildcard = parsed.isRemainderWildcard;
    }
  }

  if (pathSegments.isEmpty) {
    return const _NormalizedPath(
      path: '/',
      shapePath: '/',
      paramNames: [],
      wildcardParam: null,
      hasRemainderWildcard: false,
      catchAllKind: null,
      isTerminalRemainderWildcard: false,
    );
  }

  return _NormalizedPath(
    path: '/${pathSegments.join('/')}',
    shapePath: '/${shapeSegments.join('/')}',
    paramNames: paramNames,
    wildcardParam: wildcardParam,
    hasRemainderWildcard: hasRemainderWildcard,
    catchAllKind: catchAllKind,
    isTerminalRemainderWildcard: isTerminalRemainderWildcard,
  );
}

_ParsedSegment _parseSegment(
  String raw, {
  required bool isTerminal,
  required String routeShape,
}) {
  if (raw == '[_]') {
    return const _ParsedSegment(path: '*', shape: '*');
  }

  if (raw.startsWith('[[') && raw.endsWith(']]')) {
    final inner = raw.substring(2, raw.length - 2);
    if (inner.startsWith('...')) {
      final name = inner.substring(3);
      _requireParamName(
        name,
        routeShape,
        'Invalid repeated wildcard name in route segment',
      );
      return _ParsedSegment(path: ':$name*', shape: ':*', paramNames: [name]);
    }

    final param = _parseParamToken(
      inner,
      routeShape: routeShape,
      errorPrefix: 'Invalid optional parameter in route segment',
    );
    return _ParsedSegment(
      path: ':${param.name}${param.regex}?',
      shape: ':${param.shapeSuffix}?',
      paramNames: [param.name],
    );
  }

  if (raw.startsWith('[') && raw.endsWith(']')) {
    final inner = raw.substring(1, raw.length - 1);
    if (inner.startsWith('...')) {
      final rest = inner.substring(3);
      if (!isTerminal) {
        throw RouteScanException(
          'Catch-all segment must be terminal: "$routeShape".',
        );
      }
      if (rest.isEmpty) {
        return const _ParsedSegment(
          path: '**',
          shape: '**',
          isRemainderWildcard: true,
          catchAllKind: false,
        );
      }
      if (rest.endsWith('+')) {
        final name = rest.substring(0, rest.length - 1);
        _requireParamName(
          name,
          routeShape,
          'Invalid repeated wildcard name in route segment',
        );
        return _ParsedSegment(path: ':$name+', shape: ':+', paramNames: [name]);
      }
      _requireParamName(
        rest,
        routeShape,
        'Invalid catch-all name in route segment',
      );
      return _ParsedSegment(
        path: '**:$rest',
        shape: '**',
        paramNames: [rest],
        wildcardParam: rest,
        isRemainderWildcard: true,
        catchAllKind: true,
      );
    }
  }

  final path = StringBuffer();
  final shape = StringBuffer();
  final names = <String>[];
  var cursor = 0;

  while (cursor < raw.length) {
    final open = raw.indexOf('[', cursor);
    if (open < 0) {
      final literal = raw.substring(cursor);
      path.write(literal);
      shape.write(literal);
      break;
    }

    if (open > cursor) {
      final literal = raw.substring(cursor, open);
      path.write(literal);
      shape.write(literal);
    }

    final close = _findTokenEnd(raw, open + 1);
    if (close < 0) {
      throw RouteScanException('Unclosed route token in segment "$raw".');
    }

    final token = raw.substring(open + 1, close);
    if (token == '_') {
      path.write('*');
      shape.write('*');
    } else {
      if (token.startsWith('...') ||
          token.startsWith('[') ||
          token.endsWith(']')) {
        throw RouteScanException(
          'Reserved wildcard or optional syntax must use the whole segment: "$raw".',
        );
      }

      final param = _parseParamToken(
        token,
        routeShape: routeShape,
        errorPrefix: 'Invalid parameter token in route segment',
      );
      names.add(param.name);
      path
        ..write(':')
        ..write(param.name)
        ..write(param.regex);
      shape
        ..write(':')
        ..write(param.shapeSuffix);
    }

    cursor = close + 1;
  }

  return _ParsedSegment(
    path: path.toString(),
    shape: shape.toString(),
    paramNames: names,
  );
}

_ParsedParam _parseParamToken(
  String token, {
  required String routeShape,
  required String errorPrefix,
}) {
  final regexStart = token.indexOf('(');
  if (regexStart < 0) {
    _requireParamName(token, routeShape, errorPrefix);
    return _ParsedParam(name: token, regex: '', shapeSuffix: '');
  }

  if (!token.endsWith(')')) {
    throw RouteScanException('$errorPrefix: "$token" in "$routeShape".');
  }

  final name = token.substring(0, regexStart);
  _requireParamName(name, routeShape, errorPrefix);
  final regex = token.substring(regexStart);
  if (regex == '()') {
    throw RouteScanException('$errorPrefix: "$token" in "$routeShape".');
  }

  return _ParsedParam(name: name, regex: regex, shapeSuffix: regex);
}

void _requireParamName(String name, String routeShape, String errorPrefix) {
  final paramName = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
  if (!paramName.hasMatch(name)) {
    throw RouteScanException('$errorPrefix: "$name" in "$routeShape".');
  }
}

int _findTokenEnd(String raw, int start) {
  var parenDepth = 0;
  var classDepth = 0;
  var escaped = false;

  for (var i = start; i < raw.length; i++) {
    final char = raw[i];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char == r'\') {
      escaped = true;
      continue;
    }
    if (char == '[' && parenDepth > 0) {
      classDepth += 1;
      continue;
    }
    if (char == ']' && classDepth > 0) {
      classDepth -= 1;
      continue;
    }
    if (char == '(' && classDepth == 0) {
      parenDepth += 1;
      continue;
    }
    if (char == ')' && classDepth == 0 && parenDepth > 0) {
      parenDepth -= 1;
      continue;
    }
    if (char == ']' && parenDepth == 0 && classDepth == 0) {
      return i;
    }
  }

  return -1;
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
  final HttpMethod? method;
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
    required this.hasRemainderWildcard,
    required this.catchAllKind,
    required this.isTerminalRemainderWildcard,
  });

  final String path;
  final String shapePath;
  final List<String> paramNames;
  final String? wildcardParam;
  final bool hasRemainderWildcard;
  final bool? catchAllKind;
  final bool isTerminalRemainderWildcard;
}

final class _ShapeRecord {
  const _ShapeRecord(this.source, this.names);

  final String source;
  final List<String> names;
}

final class _ScopedHandlerFile {
  const _ScopedHandlerFile({required this.method});

  final HttpMethod? method;
}

final class _ParsedSegment {
  const _ParsedSegment({
    required this.path,
    required this.shape,
    this.paramNames = const [],
    this.wildcardParam,
    this.isRemainderWildcard = false,
    this.catchAllKind,
  });

  final String path;
  final String shape;
  final List<String> paramNames;
  final String? wildcardParam;
  final bool isRemainderWildcard;
  final bool? catchAllKind;
}

final class _ParsedParam {
  const _ParsedParam({
    required this.name,
    required this.regex,
    required this.shapeSuffix,
  });

  final String name;
  final String regex;
  final String shapeSuffix;
}
