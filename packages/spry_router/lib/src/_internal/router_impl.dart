import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

import '../route.dart';
import '../router.dart';

const String __spryRouterPrefix = '__spry_router';

class RouterImpl extends Router {
  RouterImpl([this.prefix = '']);

  final String prefix;

  Middleware? middleware;

  final Map<String, Middleware> paramsMiddleware = {};
  final List<dynamic> routes = [];

  @override
  Route mount(String prefix, Handler handler) {
    if (!prefix.startsWith('/')) {
      throw ArgumentError.value(prefix, 'prefix', 'must start with "/"');
    }

    // Create full prefix.
    final String fullPrefix = this.prefix + prefix;

    // Create full prefix path name, format: "{__spryRouterMountPrefix}_{hash}"
    final String name = '${__spryRouterPrefix}_${fullPrefix.hashCode}';

    // Create a route path for the full prefix.
    final String path = '$fullPrefix/:$name*';

    // Add the route.
    return all(path, handler);
  }

  @override
  void param(String name, Middleware middleware) {
    paramsMiddleware[name] =
        paramsMiddleware[name]?.use(middleware) ?? middleware;
  }

  @override
  Route route(String verb, String path, Handler handler) {
    throw UnimplementedError();
  }

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }
}
