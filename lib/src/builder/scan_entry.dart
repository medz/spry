import 'package:ht/ht.dart' show HttpMethod;

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
  final Map<String, Object?>? openapi;
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

/// Kinds of scan events emitted by the scanner.
enum ScanEntryType {
  /// A discovered route entry.
  route,

  /// A discovered global middleware entry.
  globalMiddleware,

  /// A discovered scoped middleware entry.
  scopedMiddleware,

  /// A discovered scoped error handler entry.
  scopedError,

  /// A discovered fallback route entry.
  fallback,

  /// A discovered hooks entry.
  hooks,
}

/// A scanner event emitted by the scanner.
final class ScanEntry {
  /// Creates a typed scan entry.
  const ScanEntry._({
    required this.type,
    this.route,
    this.middleware,
    this.error,
    this.hooks,
  });

  /// Creates a route scan event.
  factory ScanEntry.route(RouteEntry route) {
    return ScanEntry._(type: ScanEntryType.route, route: route);
  }

  /// Creates a global middleware scan event.
  factory ScanEntry.globalMiddleware(MiddlewareEntry middleware) {
    return ScanEntry._(
      type: ScanEntryType.globalMiddleware,
      middleware: middleware,
    );
  }

  /// Creates a scoped middleware scan event.
  factory ScanEntry.scopedMiddleware(MiddlewareEntry middleware) {
    return ScanEntry._(
      type: ScanEntryType.scopedMiddleware,
      middleware: middleware,
    );
  }

  /// Creates a scoped error scan event.
  factory ScanEntry.scopedError(ErrorEntry error) {
    return ScanEntry._(type: ScanEntryType.scopedError, error: error);
  }

  /// Creates a fallback route scan event.
  factory ScanEntry.fallback(RouteEntry route) {
    return ScanEntry._(type: ScanEntryType.fallback, route: route);
  }

  /// Creates a hooks scan event.
  factory ScanEntry.hooks(HooksEntry hooks) {
    return ScanEntry._(type: ScanEntryType.hooks, hooks: hooks);
  }

  /// Scan event category.
  final ScanEntryType type;

  /// Route payload when [type] is [ScanEntryType.route] or fallback.
  final RouteEntry? route;

  /// Middleware payload when [type] represents middleware.
  final MiddlewareEntry? middleware;

  /// Error payload when [type] is [ScanEntryType.scopedError].
  final ErrorEntry? error;

  /// Hooks payload when [type] is [ScanEntryType.hooks].
  final HooksEntry? hooks;
}
