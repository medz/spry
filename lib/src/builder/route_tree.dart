import 'package:ht/ht.dart' show HttpMethod;

final class RouteTree {
  const RouteTree({
    this.routes = const [],
    this.globalMiddleware = const [],
    this.scopedMiddleware = const [],
    this.scopedErrors = const [],
    this.fallback,
    this.hooks,
  });

  final List<RouteEntry> routes;
  final List<MiddlewareEntry> globalMiddleware;
  final List<MiddlewareEntry> scopedMiddleware;
  final List<ErrorEntry> scopedErrors;
  final RouteEntry? fallback;
  final HooksEntry? hooks;
}

final class HooksEntry {
  const HooksEntry({
    required this.filePath,
    this.hasOnStart = false,
    this.hasOnStop = false,
    this.hasOnError = false,
  });

  final String filePath;
  final bool hasOnStart;
  final bool hasOnStop;
  final bool hasOnError;
}

final class RouteEntry {
  const RouteEntry({
    required this.filePath,
    required this.path,
    required this.method,
    this.wildcardParam,
  });

  final String filePath;
  final String path;
  final HttpMethod? method;
  final String? wildcardParam;
}

final class MiddlewareEntry {
  const MiddlewareEntry({
    required this.filePath,
    required this.path,
    this.method,
  });

  final String filePath;
  final String path;
  final HttpMethod? method;
}

final class ErrorEntry {
  const ErrorEntry({required this.filePath, required this.path, this.method});

  final String filePath;
  final String path;
  final HttpMethod? method;
}
