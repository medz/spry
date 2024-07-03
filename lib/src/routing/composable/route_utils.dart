import 'package:routingkit/routingkit.dart' show Router;

import '../../composable/get_context.dart';
import '../../event.dart';
import '../_routing_keys.dart';
import '../route.dart';

Route? getRoute(Event event) => getContext(event).get<Route?>(kRoute);

String? getRouteId(Event event) => getRoute(event)?.id;

String makeRoutePath(
  Event event,
  String route, {
  Map<String, String>? params,
  Iterable<String>? wildcard,
  String? catchall,
}) {
  return getContext(event)
      .get<Router>(kRouter)
      .buildPath(route, params: params, wildcard: wildcard, catchall: catchall);
}
