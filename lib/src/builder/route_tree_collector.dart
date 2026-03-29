import 'route_tree.dart';
import 'scan_entry.dart';

/// Collects streamed scan events back into the legacy [RouteTree] shape.
Future<RouteTree> collectRouteTree(Stream<ScanEntry> entries) async {
  final routes = <RouteEntry>[];
  final globalMiddleware = <MiddlewareEntry>[];
  final scopedMiddleware = <MiddlewareEntry>[];
  final scopedErrors = <ErrorEntry>[];
  RouteEntry? fallback;
  HooksEntry? hooks;

  await for (final entry in entries) {
    switch (entry.type) {
      case ScanEntryType.route:
        routes.add(entry.route!);
      case ScanEntryType.globalMiddleware:
        globalMiddleware.add(entry.middleware!);
      case ScanEntryType.scopedMiddleware:
        scopedMiddleware.add(entry.middleware!);
      case ScanEntryType.scopedError:
        scopedErrors.add(entry.error!);
      case ScanEntryType.fallback:
        fallback = entry.route!;
      case ScanEntryType.hooks:
        hooks = entry.hooks!;
    }
  }

  return RouteTree(
    routes: routes,
    globalMiddleware: globalMiddleware,
    scopedMiddleware: scopedMiddleware,
    scopedErrors: scopedErrors,
    fallback: fallback,
    hooks: hooks,
  );
}
