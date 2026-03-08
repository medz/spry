import 'package:roux/roux.dart';

import '../middleware.dart';

Router<MiddlewareRoute> createMiddlewareRouter(
  Iterable<MiddlewareRoute> routes,
) {
  final router = Router<MiddlewareRoute>();
  for (final route in routes) {
    router.add(route.path, route, method: route.method);
  }

  return router;
}
