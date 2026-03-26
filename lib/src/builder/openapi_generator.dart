import 'dart:convert';

import 'package:ht/ht.dart' show HttpMethod;
import 'package:path/path.dart' as p;

import '../../config.dart';
import 'config.dart';
import 'generated_file.dart';
import 'route_tree.dart';

/// Generates the optional OpenAPI document file for the scanned route tree.
GeneratedFile? generateOpenApiDocument(RouteTree tree, BuildConfig config) {
  final openapiConfig = config.openapi;
  if (openapiConfig == null) {
    return null;
  }

  final paths = <String, Map<String, Object?>>{};
  final liftedComponents =
      <({String source, Map<String, Object?> components})>[];
  final routeGroups = <String, List<RouteEntry>>{};
  for (final route in tree.routes) {
    if (route.openapi == null) {
      continue;
    }
    routeGroups.putIfAbsent(route.path, () => <RouteEntry>[]).add(route);
  }

  for (final entry in routeGroups.entries) {
    final path = _toOpenApiPath(entry.key);
    final operations = <String, dynamic>{};
    Map<String, Object?>? anyMethodOperation;
    final explicitOperations = <HttpMethod, Map<String, Object?>>{};

    for (final route in entry.value) {
      final extracted = _extractGlobalComponents(route.openapi!);
      if (extracted.globalComponents != null) {
        liftedComponents.add((
          source: route.filePath,
          components: extracted.globalComponents!,
        ));
      }
      if (route.method == null) {
        anyMethodOperation = extracted.operation;
      } else {
        explicitOperations[route.method!] = extracted.operation;
      }
    }

    if (anyMethodOperation case final operation?) {
      for (final method in _openApiExpandedMethods) {
        // Deep-clone so each method gets an independent copy of any nested
        // lists or maps (e.g. parameters, responses).
        operations[method] =
            _deepCloneJsonValue(operation) as Map<String, Object?>;
      }
    }

    for (final explicit in explicitOperations.entries) {
      operations[explicit.key.name] =
          _deepCloneJsonValue(explicit.value) as Map<String, Object?>;
    }

    if (operations.isNotEmpty) {
      _ensurePathParams(path, operations);
      paths[path] = operations;
    }
  }

  // Deep-clone the document config so the mutable document map is independent
  // of the config object, then stamp the required openapi version field.
  final document =
      _deepCloneJsonValue(openapiConfig.document) as Map<String, Object?>
        ..['openapi'] = '3.1.0';
  final mergedComponents = _mergeDocumentComponents(
    switch (document['components']) {
      final Map<String, Object?> components => components,
      null => <String, Object?>{},
      _ => throw StateError(
        'OpenAPI document components must be a JSON object.',
      ),
    },
    liftedComponents,
    openapiConfig.componentsMergeStrategy,
  );
  if (mergedComponents.isNotEmpty) {
    document['components'] = mergedComponents;
  } else {
    document.remove('components');
  }
  document['paths'] = paths;

  return switch (openapiConfig.output.type) {
    'route' => GeneratedFile(
      path: p.join(config.publicDir, openapiConfig.output.path),
      content: const JsonEncoder.withIndent('  ').convert(document),
      rootRelative: true,
    ),
    'local' => GeneratedFile(
      path: openapiConfig.output.path,
      content: const JsonEncoder.withIndent('  ').convert(document),
      rootRelative: true,
    ),
    _ => throw StateError(
      'Unsupported OpenAPI output type: ${openapiConfig.output.type}',
    ),
  };
}

// Ensures every `{param}` token in the OpenAPI [openApiPath] is represented
// in each operation's `parameters` list with `"in": "path"`. Parameters the
// developer has already declared are kept as-is except for `required`, which
// is always forced to `true`.
//
// OAS 3.1 mandates that path parameters always carry `required: true` — a
// path parameter that is absent means the path itself does not match, so the
// concept of an optional path parameter does not exist in OAS. Any developer-
// declared path parameter that sets `required: false` is silently corrected.
void _ensurePathParams(String openApiPath, Map<String, dynamic> operations) {
  final pathParams = RegExp(
    r'\{([^}]+)\}',
  ).allMatches(openApiPath).map((m) => m.group(1)!).toSet();
  if (pathParams.isEmpty) return;

  for (final operation in operations.values.cast<Map<String, Object?>>()) {
    final documented = <String>{};
    if (operation['parameters'] case final List params) {
      for (final param in params) {
        if (param case final Map p
            when p['in'] == 'path' && p['name'] is String) {
          documented.add(p['name'] as String);
          // OAS 3.1 §4.8.12.1: required MUST be true for path parameters.
          p['required'] = true;
        }
      }
    }

    final missing = pathParams.difference(documented);
    if (missing.isEmpty) continue;

    final existing = switch (operation['parameters']) {
      final List value => value,
      _ => <Object?>[],
    };
    for (final name in missing) {
      existing.add({
        'name': name,
        'in': 'path',
        'required': true,
        'schema': {'type': 'string'},
      });
    }
    operation['parameters'] = existing;
  }
}

// Excludes `head` and `trace`: these are rarely used in REST APIs and most
// OpenAPI tooling (e.g. Swagger UI) does not render them meaningfully, so
// expanding a method-less route to include them would add noise without value.
const _openApiExpandedMethods = <String>[
  'get',
  'post',
  'put',
  'patch',
  'delete',
  'options',
];

const _globalComponentsKey = 'x-spry-openapi-global-components';

String _toOpenApiPath(String path) {
  return path
      .replaceAllMapped(
        RegExp(r'\*\*:([A-Za-z_][A-Za-z0-9_]*)'),
        (match) => '{${match[1]}}',
      )
      .replaceAllMapped(
        RegExp(r':([A-Za-z_][A-Za-z0-9_]*)(?:\([^)]*\))?[\?\+\*]?'),
        (match) => '{${match[1]}}',
      );
}

Map<String, Object?> _mergeDocumentComponents(
  Map<String, Object?> base,
  List<({String source, Map<String, Object?> components})> lifted,
  OpenAPIComponentsMergeStrategy strategy,
) {
  final result = _deepCloneJsonValue(base) as Map<String, Object?>;
  final sources = <String, String>{};

  for (final categoryEntry in base.entries) {
    final category = categoryEntry.key;
    final bucket = categoryEntry.value;
    if (bucket is! Map) {
      throw StateError(
        'OpenAPI components bucket `$category` must be a JSON object.',
      );
    }
    for (final componentEntry in bucket.entries) {
      final name = '${componentEntry.key}';
      sources['$category.$name'] =
          'openapi.document.components.$category.$name';
    }
  }

  for (final liftedEntry in lifted) {
    final components = liftedEntry.components;
    for (final categoryEntry in components.entries) {
      final category = categoryEntry.key;
      final incomingBucket = categoryEntry.value;
      if (incomingBucket is! Map) {
        throw StateError(
          'OpenAPI components bucket `$category` must be a JSON object.',
        );
      }

      final existingBucket = result.putIfAbsent(
        category,
        () => <String, Object?>{},
      );
      if (existingBucket is! Map) {
        throw StateError(
          'OpenAPI components bucket `$category` must be a JSON object.',
        );
      }

      final existingTyped = existingBucket as Map<String, Object?>;

      for (final componentEntry in incomingBucket.entries) {
        final name = '${componentEntry.key}';
        final key = '$category.$name';
        final incomingValue = _deepCloneJsonValue(componentEntry.value);
        if (!existingTyped.containsKey(name)) {
          existingTyped[name] = incomingValue;
          sources[key] = liftedEntry.source;
          continue;
        }

        final currentValue = existingTyped[name];
        if (_jsonDeepEquals(currentValue, incomingValue)) {
          continue;
        }

        if (strategy == OpenAPIComponentsMergeStrategy.deepMerge) {
          existingTyped[name] = _deepMergeJsonValues(
            currentValue,
            incomingValue,
            context: 'components.$category.$name',
            currentSource: sources[key] ?? 'unknown',
            incomingSource: liftedEntry.source,
          );
          continue;
        }

        throw StateError(
          'Conflicting OpenAPI component `$category.$name` '
          '(current: ${sources[key] ?? 'unknown'}, incoming: ${liftedEntry.source}).',
        );
      }
    }
  }
  return result;
}

({Map<String, Object?> operation, Map<String, Object?>? globalComponents})
_extractGlobalComponents(Map<String, Object?> operation) {
  final cloned = Map<String, Object?>.from(operation);
  final lifted = cloned.remove(_globalComponentsKey);
  if (lifted == null) {
    return (operation: cloned, globalComponents: null);
  }
  if (lifted is! Map) {
    throw StateError('`$_globalComponentsKey` must be a JSON object.');
  }
  return (
    operation: cloned,
    globalComponents: Map<String, Object?>.from(lifted),
  );
}

Object? _deepMergeJsonValues(
  Object? current,
  Object? incoming, {
  required String context,
  required String currentSource,
  required String incomingSource,
}) {
  if (current is Map && incoming is Map) {
    final result = Map<String, Object?>.from(current);
    for (final entry in incoming.entries) {
      final key = '${entry.key}';
      if (!result.containsKey(key)) {
        result[key] = _deepCloneJsonValue(entry.value);
        continue;
      }
      result[key] = _deepMergeJsonValues(
        result[key],
        entry.value,
        context: '$context.$key',
        currentSource: currentSource,
        incomingSource: incomingSource,
      );
    }
    return result;
  }

  if (_jsonDeepEquals(current, incoming)) {
    return _deepCloneJsonValue(current);
  }

  throw StateError(
    'Conflicting OpenAPI component value at `$context` during deep merge '
    '(current: $currentSource, incoming: $incomingSource).',
  );
}

Object? _deepCloneJsonValue(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        '${entry.key}': _deepCloneJsonValue(entry.value),
    };
  }
  if (value is List) {
    return [for (final item in value) _deepCloneJsonValue(item)];
  }
  return value;
}

bool _jsonDeepEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) {
      return false;
    }
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) {
        return false;
      }
      if (!_jsonDeepEquals(entry.value, b[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!_jsonDeepEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}
