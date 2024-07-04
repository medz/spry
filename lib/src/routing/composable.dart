import 'package:routingkit/routingkit.dart' as routingkit;

import '../composable/get_context.dart';
import '../event.dart';
import '_routing_keys.dart';
import 'route.dart';

typedef Params = routingkit.Params;

Params getRouteParams(Event event) {
  return getContext(event).upsert(kParams, () => Params());
}

T getValidatedRouteParams<T>(Event event, T Function(Params params) validator) {
  return validator(getRouteParams(event));
}

String? getRouteCatchallParam(Event event) => getRouteParams(event).catchall;
String? getRouteParam(Event event, String name) =>
    getRouteParams(event).call(name);
Iterable<String> getRouteParamValues(Event event, String name) =>
    getRouteParams(event).valuesOf(name);

Route? getRoute(Event event) => getContext(event).getOrNull<Route>(kRoute);

String makeRoutePath(
  Event event,
  String route, {
  Map<String, String>? params,
  Iterable<String>? wildcard,
  String? catchall,
}) {
  return getContext(event)
      .get<routingkit.Router>(kRouter)
      .buildPath(route, params: params, wildcard: wildcard, catchall: catchall);
}
