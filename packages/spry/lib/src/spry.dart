import 'package:routingkit/routingkit.dart' as routingkit;

import 'handler/handler.dart';
import 'routing/routes_builder.dart';

/// Spry application.
class Spry implements RoutesBuilder {
  /// Spry using [Router].
  late final _router = routingkit.createRouter<Handler>();

  @override
  void addRoute(String method, String route, Handler handler) {
    routingkit.addRoute(_router, method, route, handler);
  }

  resolve(String method, String path) {
    final route = routingkit.findRoute(_router, method, path)?.lastOrNull;
    if (route == null) return;

    return (route.data, route.params);
  }
}
