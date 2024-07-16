import 'package:routingkit/routingkit.dart' as routingkit;
import 'package:spry/src/event/event.dart';
import 'package:spry/src/http/response.dart';

import 'handler.dart';
import 'routing/routes.dart';

/// Spry application.
class Spry implements Routes {
  final _hRouter = routingkit.createRouter<Handler>();

  @override
  void addRoute(String method, String path, Handler handler) {
    routingkit.addRoute(_hRouter, method, path, handler);
  }

  /// Returns a added handler wraped method data.
  routingkit.MatchedRoute<Handler>? resolve(String method, String path) {
    return routingkit.findRoute(_hRouter, method, path)?.lastOrNull;
  }

  /// Returns the Spry application stack handler.
  Handler toHandler() => _SpryStackHandler(this);
}

/// The Spry stack handler.
class _SpryStackHandler implements Handler {
  @override
  Future<Response> handle(Event event) {
    throw UnimplementedError();
    // final route = routingkit.findRoute(app)
  }
}
