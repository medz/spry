import 'package:routingkit/routingkit.dart';

import '../http/closure_based_responder.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderMethod on RoutesBuilder {
  Route route(
    String method,
    String path,
    ClosureResponder closure, {
    String? description,
  }) {
    final responder = ClosureBasedResponder(closure);
    final route = Route(
      method: method.toLowerCase(),
      path: path.pathComponents,
      responder: responder,
      description: description,
    );

    add(route);

    return route;
  }

  Route get(String path, ClosureResponder closure) =>
      route('get', path, closure);
  Route post(String path, ClosureResponder closure) =>
      route('post', path, closure);
  Route patch(String path, ClosureResponder closure) =>
      route('patch', path, closure);
  Route put(String path, ClosureResponder closure) =>
      route('put', path, closure);
  Route delete(String path, ClosureResponder closure) =>
      route('delete', path, closure);
}
