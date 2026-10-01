import 'package:roux/roux.dart';

import '../../version.dart';
import '../builder/config.dart';
import '../builder/client_generator.dart'
    show resolveClientPkgDir, resolveClientOutputDir;
import '../builder/scan_entry.dart';
import '../routing.dart' show matchHandler;

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
  final routes = state.entries.where((e) => e.route != null);
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
      if (entry.route case final route?) _routeToJson(route),
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
  final requestedMethod = args?['method'];
  final requestedPath = args?['path'];
  if (requestedMethod != null && requestedMethod is! String ||
      requestedPath != null && requestedPath is! String) {
    throw ArgumentError('method and path must be strings');
  }
  final method = (requestedMethod as String?)?.toUpperCase() ?? 'GET';
  final path = requestedPath as String? ?? '/';

  final router = Router<RouteEntry>(caseSensitive: state.config.caseSensitive);
  final fallback = Router<RouteEntry>(
    caseSensitive: state.config.caseSensitive,
  );
  final middleware = Router<ScanEntry>(
    caseSensitive: state.config.caseSensitive,
  );
  final errors = Router<ErrorEntry>(caseSensitive: state.config.caseSensitive);
  for (final entry in state.entries) {
    if (entry.route case final route?) {
      final destination = entry.type == ScanEntryType.fallback
          ? fallback
          : router;
      destination.add(route.path, route, method: route.method?.value);
    }
    if (entry.middleware case final mw?) {
      middleware.add(mw.path, entry, method: mw.method?.value);
    }
    if (entry.error case final error?) {
      errors.add(error.path, error, method: error.method?.value);
    }
  }
  final match = matchHandler(router, path, method);
  final fallbackMatch = match == null
      ? matchHandler(fallback, path, method)
      : null;
  final selected = match ?? fallbackMatch;

  return {
    'method': method,
    'path': path,
    'matched_routes': [
      if (selected != null)
        {
          ..._routeToJson(selected.data),
          'params': match?.params ?? <String, String>{},
        },
    ],
    'middleware_chain': [
      for (final match in middleware.findAll(
        path,
        method: method,
        includeAny: true,
      ))
        {
          'type': match.data.type == ScanEntryType.globalMiddleware
              ? 'global'
              : 'scoped',
          'path': match.data.middleware!.path,
          'method': match.data.middleware!.method?.value,
          'file': match.data.middleware!.filePath,
        },
    ],
    'error_handlers': [
      for (final match
          in errors.findAll(path, method: method, includeAny: true).reversed)
        {
          'path': match.data.path,
          'method': match.data.method?.value,
          'file': match.data.filePath,
        },
    ],
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
  final pkgDir = resolveClientPkgDir(state.config, client);
  return {
    'enabled': true,
    'pkg_dir': pkgDir,
    'output_dir': resolveClientOutputDir(pkgDir, client),
    'endpoint': client.endpoint,
  };
}

Map<String, dynamic> _routeToJson(RouteEntry route) => {
  'path': route.path,
  'method': route.method?.value,
  'file': route.filePath,
  'wildcard_param': ?route.wildcardParam,
};
