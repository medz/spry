import 'package:roux/roux.dart';

import '../error_route.dart';

Router<ErrorRoute> createErrorRouter(Iterable<ErrorRoute> routes) {
  final router = Router<ErrorRoute>();
  for (final route in routes) {
    router.add(route.path, route, method: route.method);
  }

  return router;
}

Iterable<RouteMatch<ErrorRoute>> collectErrors(
  Router<ErrorRoute> router,
  String path,
  String method,
) {
  return router.matchAll(path, method: method).reversed;
}
