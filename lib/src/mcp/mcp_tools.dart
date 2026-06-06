import '../../version.dart';
import '../builder/config.dart';
import '../builder/scan_entry.dart';

/// A tool definition exposed to MCP clients.
final class ToolDef {
  /// Creates a tool definition.
  const ToolDef({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  /// Unique tool name (e.g. `spry.list_routes`).
  final String name;

  /// Human-readable description shown to clients.
  final String description;

  /// JSON Schema describing the tool's input parameters.
  final Map<String, dynamic> inputSchema;
}

/// All Spry MCP tools available to clients.
const toolDefinitions = [
  ToolDef(
    name: 'spry.get_project_info',
    description:
        'Get a summary of the Spry project: route count, '
        'middleware count, target, version, and output directory.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDef(
    name: 'spry.get_config',
    description:
        'Get the effective Spry build configuration: target, port, '
        'host, directories, case sensitivity, reload strategy, and more.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDef(
    name: 'spry.list_routes',
    description:
        'List all discovered routes with their HTTP method, '
        'path pattern, source file, and wildcard params.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDef(
    name: 'spry.list_middleware',
    description:
        'List all global and scoped middleware with their scope '
        'path, HTTP method restriction, and source file.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDef(
    name: 'spry.list_error_handlers',
    description:
        'List all scoped error handlers with their scope path, '
        'HTTP method restriction, and source file.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDef(
    name: 'spry.explain_route',
    description:
        'Given an HTTP method and path, find the matching route '
        'and return its source file, parameters, and relevant middleware '
        'and error handlers in scope.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'method': {
          'type': 'string',
          'description': 'HTTP method (GET, POST, PUT, DELETE, etc.)',
        },
        'path': {
          'type': 'string',
          'description': 'Request path (e.g. /users/123)',
        },
      },
      'required': ['method', 'path'],
    },
  ),
  ToolDef(
    name: 'spry.get_openapi_status',
    description:
        'Get the OpenAPI generation configuration and status: '
        'output path, UI route, included paths, and schema file location.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDef(
    name: 'spry.get_client_status',
    description:
        'Get the client generation configuration and status: '
        'output directory, language, and package name.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
];

/// Project state available to all tool handlers.
final class ProjectState {
  /// Creates project state from a loaded config and scanned entries.
  const ProjectState({required this.config, required this.entries});

  /// The effective build configuration.
  final BuildConfig config;

  /// All scanned project entries (routes, middleware, errors, hooks).
  final List<ScanEntry> entries;
}

/// Handles a tool call and returns the result value.
Object? handleToolCall(
  String name,
  Map<String, dynamic>? args,
  ProjectState state,
) {
  return switch (name) {
    'spry.get_project_info' => _getProjectInfo(state),
    'spry.get_config' => _getConfig(state),
    'spry.list_routes' => _listRoutes(state),
    'spry.list_middleware' => _listMiddleware(state),
    'spry.list_error_handlers' => _listErrorHandlers(state),
    'spry.explain_route' => _explainRoute(state, args),
    'spry.get_openapi_status' => _getOpenApiStatus(state),
    'spry.get_client_status' => _getClientStatus(state),
    _ => throw ArgumentError('Unknown tool: $name'),
  };
}

Map<String, dynamic> _getProjectInfo(ProjectState state) {
  final config = state.config;
  final routes = state.entries.where((e) => e.type == ScanEntryType.route);
  final middleware = state.entries.where(
    (e) =>
        e.type == ScanEntryType.globalMiddleware ||
        e.type == ScanEntryType.scopedMiddleware,
  );
  final errors = state.entries.where(
    (e) => e.type == ScanEntryType.scopedError,
  );

  return {
    'version': version,
    'target': config.target.name,
    'route_count': routes.length,
    'middleware_count': middleware.length,
    'error_handler_count': errors.length,
    'output_dir': config.outputDir,
    'has_openapi': config.openapi != null,
    'has_client': config.client != null,
  };
}

Map<String, dynamic> _getConfig(ProjectState state) {
  final config = state.config;
  return {
    'host': config.host,
    'port': config.port,
    'target': config.target.name,
    'routes_dir': config.routesDir,
    'middleware_dir': config.middlewareDir,
    'public_dir': config.publicDir,
    'output_dir': config.outputDir,
    'case_sensitive': config.caseSensitive,
    'handler_cache_capacity': config.handlerCacheCapacity,
    'reload_strategy': config.reload.name,
    'wrangler_config': config.wranglerConfig,
  };
}

List<Map<String, dynamic>> _listRoutes(ProjectState state) {
  return [
    for (final entry in state.entries)
      if (entry.type == ScanEntryType.route && entry.route != null)
        _routeToJson(entry.route!),
  ];
}

List<Map<String, dynamic>> _listMiddleware(ProjectState state) {
  return [
    for (final entry in state.entries)
      if (entry.middleware != null)
        {
          'type': entry.type == ScanEntryType.globalMiddleware
              ? 'global'
              : 'scoped',
          'path': entry.middleware!.path,
          'method': entry.middleware!.method?.value,
          'file': entry.middleware!.filePath,
        },
  ];
}

List<Map<String, dynamic>> _listErrorHandlers(ProjectState state) {
  return [
    for (final entry in state.entries)
      if (entry.type == ScanEntryType.scopedError && entry.error != null)
        {
          'path': entry.error!.path,
          'method': entry.error!.method?.value,
          'file': entry.error!.filePath,
        },
  ];
}

Map<String, dynamic> _explainRoute(
  ProjectState state,
  Map<String, dynamic>? args,
) {
  final method = (args?['method'] as String?)?.toUpperCase() ?? 'GET';
  final path = args?['path'] as String? ?? '/';

  // Find matching routes by comparing file paths to the request path.
  final routes = <Map<String, dynamic>>[];
  for (final entry in state.entries) {
    if (entry.type != ScanEntryType.route || entry.route == null) continue;
    final route = entry.route!;
    final routeMethod = route.method?.value;
    if (routeMethod != null && routeMethod != method) continue;
    if (pathMatches(route.path, path)) {
      routes.add({
        ..._routeToJson(route),
        'params': extractParams(route.path, path),
      });
    }
  }

  // Collect middleware that apply to this path (scoped + global).
  final middleware = <Map<String, dynamic>>[];
  for (final entry in state.entries) {
    if (entry.middleware == null) continue;
    final mw = entry.middleware!;
    // Skip method-restricted middleware that doesn't match.
    if (mw.method != null && mw.method!.value != method) continue;
    if (pathIsPrefix(mw.path, path)) {
      middleware.add({
        'type': entry.type == ScanEntryType.globalMiddleware
            ? 'global'
            : 'scoped',
        'path': mw.path,
        'method': mw.method?.value,
        'file': mw.filePath,
      });
    }
  }

  // Collect error handlers that apply.
  final errors = <Map<String, dynamic>>[];
  for (final entry in state.entries) {
    if (entry.type != ScanEntryType.scopedError || entry.error == null) {
      continue;
    }
    final err = entry.error!;
    if (pathIsPrefix(err.path, path)) {
      errors.add({
        'path': err.path,
        'method': err.method?.value,
        'file': err.filePath,
      });
    }
  }

  return {
    'method': method,
    'path': path,
    'matched_routes': routes,
    'middleware_chain': middleware,
    'error_handlers': errors,
  };
}

Map<String, dynamic> _getOpenApiStatus(ProjectState state) {
  final openapi = state.config.openapi;
  if (openapi == null) {
    return {'enabled': false};
  }
  return {
    'enabled': true,
    'output_type': openapi.output.type,
    'output_path': openapi.output.path,
    'ui_route': openapi.ui?.route,
  };
}

Map<String, dynamic> _getClientStatus(ProjectState state) {
  final client = state.config.client;
  if (client == null) {
    return {'enabled': false};
  }
  return {
    'enabled': true,
    'output_dir': client.output,
    'endpoint': client.endpoint,
  };
}

Map<String, dynamic> _routeToJson(RouteEntry route) => {
  'path': route.path,
  'method': route.method?.value,
  'file': route.filePath,
  if (route.wildcardParam != null) 'wildcard_param': route.wildcardParam,
};

/// Simple path matching: checks if a route pattern matches a concrete path.
///
/// Handles both roux-normalized paths (`:id`, `*slug`, `/**`) and
/// Spry source syntax (`[id]`, `[...slug]`).
bool pathMatches(String pattern, String path) {
  final patternSegs = pattern.split('/').where((s) => s.isNotEmpty).toList();
  final pathSegs = path.split('/').where((s) => s.isNotEmpty).toList();

  // Optional trailing slash normalization.
  if (patternSegs.isEmpty && pathSegs.isEmpty) return true;

  for (var i = 0; i < patternSegs.length; i++) {
    final seg = patternSegs[i];

    // roux wildcard: `/**` or `/*` matches everything.
    if (seg == '**' || seg == '*') {
      return true;
    }

    // Spry wildcard: `[...name]` matches remaining segments.
    if (_isSpryWildcard(seg)) {
      return true;
    }

    // roux named catch-all: `**:param` matches remaining segments.
    if (seg.startsWith('**') && seg.length > 2) {
      return true;
    }

    // roux catch-all: `*name` matches remaining segments.
    if (seg.startsWith('*') && !seg.startsWith('**')) {
      return true;
    }

    // roux param: `:name` or `:name(regex)` — matches any single segment.
    if (seg.startsWith(':')) {
      if (i >= pathSegs.length) return false;
      continue;
    }

    // Spry param: `[name]` or `[name=regex]` — matches any single segment.
    if (_isSpryParam(seg)) {
      if (i >= pathSegs.length) return false;
      continue;
    }

    // Literal segment must match exactly.
    if (i >= pathSegs.length) return false;
    if (seg != pathSegs[i]) return false;
  }

  return patternSegs.length == pathSegs.length;
}

bool _isSpryWildcard(String seg) =>
    seg.startsWith('[...') && seg.endsWith(']');

bool _isSpryParam(String seg) =>
    seg.startsWith('[') && seg.endsWith(']') && !seg.startsWith('[...');

/// Checks if [prefix] is a path prefix of [path], used for middleware scoping.
///
/// Handles roux param segments (`:id`) in the prefix as segment wildcards
/// so that dynamic middleware scopes like `/users/:id` match paths like
/// `/users/42/something`.
bool pathIsPrefix(String prefix, String path) {
  if (prefix == '/**' || prefix == '/*') return true;

  final prefixSegs =
      prefix.split('/').where((s) => s.isNotEmpty).toList();
  final pathSegs = path.split('/').where((s) => s.isNotEmpty).toList();

  // If path has fewer segments than prefix, it can't be a prefix.
  if (pathSegs.length < prefixSegs.length) return false;

  for (var i = 0; i < prefixSegs.length; i++) {
    final seg = prefixSegs[i];

    // roux param matches any single segment.
    if (seg.startsWith(':')) continue;

    // Spry param matches any single segment.
    if (_isSpryParam(seg)) continue;

    // Literal segment must match exactly.
    if (seg != pathSegs[i]) return false;
  }

  return true;
}

/// Extracts param values from a route pattern and concrete path.
///
/// Handles both roux-normalized paths (`:id`) and Spry source syntax (`[id]`).
Map<String, String> extractParams(String pattern, String path) {
  final params = <String, String>{};
  final patternSegs = pattern.split('/').where((s) => s.isNotEmpty).toList();
  final pathSegs = path.split('/').where((s) => s.isNotEmpty).toList();

  for (var i = 0; i < patternSegs.length; i++) {
    final seg = patternSegs[i];

    // Spry wildcard: `[...name]` captures remaining segments.
    if (_isSpryWildcard(seg)) {
      final name = seg.substring(4, seg.length - 1);
      params[name] = pathSegs.skip(i).join('/');
      break;
    }

    // roux named catch-all: `**:param` captures remaining segments.
    if (seg.startsWith('**:') && seg.length > 3) {
      params[seg.substring(3)] = pathSegs.skip(i).join('/');
      break;
    }

    // roux catch-all: `*name` captures remaining segments.
    if (seg.startsWith('*') && !seg.startsWith('**')) {
      params[seg.substring(1)] = pathSegs.skip(i).join('/');
      break;
    }

    // roux param: `:name` or `:name(regex)` — captures single segment.
    if (seg.startsWith(':')) {
      final colonIdx = seg.indexOf(':');
      final parenIdx = seg.indexOf('(');
      final name = seg.substring(
        colonIdx + 1,
        parenIdx > 0 ? parenIdx : seg.length,
      );
      if (i < pathSegs.length) {
        params[name] = pathSegs[i];
      }
    }

    // Spry param: `[name]` or `[name=regex]` — captures single segment.
    if (_isSpryParam(seg)) {
      final inner = seg.substring(1, seg.length - 1);
      final name = inner.split('=').first;
      if (i < pathSegs.length) {
        params[name] = pathSegs[i];
      }
    }
  }

  return params;
}
