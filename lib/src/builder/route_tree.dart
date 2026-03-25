import 'package:ht/ht.dart' show HttpMethod;

/// Scanned route metadata used by the generator.
final class RouteTree {
  /// Creates a scanned route tree.
  const RouteTree({
    this.routes = const [],
    this.globalMiddleware = const [],
    this.scopedMiddleware = const [],
    this.scopedErrors = const [],
    this.fallback,
    this.hooks,
  });

  /// Matched route entries.
  final List<RouteEntry> routes;

  /// Global middleware entries.
  final List<MiddlewareEntry> globalMiddleware;

  /// Route-scoped middleware entries.
  final List<MiddlewareEntry> scopedMiddleware;

  /// Route-scoped error entries.
  final List<ErrorEntry> scopedErrors;

  /// Optional root fallback route.
  final RouteEntry? fallback;

  /// Optional hooks file metadata.
  final HooksEntry? hooks;
}

/// Metadata discovered from `hooks.dart`.
final class HooksEntry {
  /// Creates hooks metadata.
  const HooksEntry({
    required this.filePath,
    this.hasOnStart = false,
    this.hasOnStop = false,
    this.hasOnError = false,
  });

  /// Absolute file path.
  final String filePath;

  /// Whether `onStart` is defined.
  final bool hasOnStart;

  /// Whether `onStop` is defined.
  final bool hasOnStop;

  /// Whether `onError` is defined.
  final bool hasOnError;
}

/// Metadata for a discovered route file.
final class RouteEntry {
  /// Creates a route entry.
  const RouteEntry({
    required this.filePath,
    required this.path,
    required this.method,
    this.wildcardParam,
    this.openapi,
  });

  /// Absolute file path.
  final String filePath;

  /// Normalized route path.
  final String path;

  /// Optional HTTP method restriction.
  final HttpMethod? method;

  /// Wildcard parameter name, when present.
  final String? wildcardParam;

  /// Optional route-level OpenAPI metadata.
  final Map<String, dynamic>? openapi;
}

/// Metadata for a discovered middleware file.
final class MiddlewareEntry {
  /// Creates a middleware entry.
  const MiddlewareEntry({
    required this.filePath,
    required this.path,
    this.method,
  });

  /// Absolute file path.
  final String filePath;

  /// Normalized route scope.
  final String path;

  /// Optional HTTP method restriction.
  final HttpMethod? method;
}

/// Metadata for a discovered error file.
final class ErrorEntry {
  /// Creates an error entry.
  const ErrorEntry({required this.filePath, required this.path, this.method});

  /// Absolute file path.
  final String filePath;

  /// Normalized route scope.
  final String path;

  /// Optional HTTP method restriction.
  final HttpMethod? method;
}
