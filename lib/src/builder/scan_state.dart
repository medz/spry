// ignore_for_file: public_member_api_docs

import 'scan_entry.dart';

final class ScanState {
  const ScanState({
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

  int get routeCount => routes.length + (fallback != null ? 1 : 0);

  int get middlewareCount => globalMiddleware.length + scopedMiddleware.length;
}

Future<ScanState> collectScanState(Stream<ScanEntry> entries) async {
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
        fallback = entry.route;
      case ScanEntryType.hooks:
        hooks = entry.hooks;
    }
  }

  return ScanState(
    routes: routes,
    globalMiddleware: globalMiddleware,
    scopedMiddleware: scopedMiddleware,
    scopedErrors: scopedErrors,
    fallback: fallback,
    hooks: hooks,
  );
}
