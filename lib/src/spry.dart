import 'package:routingkit/routingkit.dart';

import 'core/application.dart';
import 'core/handler.dart';
import 'http/request.dart';
import 'http/response.dart';
import 'routing/routes_builder.dart';

class Spry implements Application, RoutesBuilder {
  final _router = createRouter();
  final _middlewareRouter = createRouter();

  @override
  Future<Response> fetch(Request request, [Map? locals]) {
    // TODO: implement fetch
    throw UnimplementedError();
  }

  @override
  // TODO: implement handler
  Handler get handler => throw UnimplementedError();

  @override
  Handler resolve(String method, String path) {
    // TODO: implement resolve
    throw UnimplementedError();
  }

  @override
  void addRoute(String method, String route, Handler handler) {
    // TODO: implement addRoute
    throw UnimplementedError();
  }
}
