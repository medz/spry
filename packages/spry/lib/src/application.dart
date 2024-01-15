import 'dart:io';

import 'package:logging/logging.dart';

import '_internal/map+value_of.dart';
import 'routing/route.dart';
import 'routing/routes.dart';
import 'routing/routes_builder.dart';

class Application implements RoutesBuilder {
  final HttpServer server;
  late final Map locals;

  Application(this.server, {Map? locals}) {
    this.locals = locals ?? {};

    server.defaultResponseHeaders.set('x-powered-by', 'Spry/3.0.0');
  }

  /// Returns spry application logger.
  Logger get logger {
    return locals.valueOf(#spry.logger, (_) {
      return locals[#spry.logger] = Logger('spry');
    });
  }

  /// Returns spry application routes.
  Routes get routes {
    return locals.valueOf(#spry.routes, (_) {
      return locals[#spry.routes] = Routes();
    });
  }

  @override
  void addRoute(Route route) => routes.addRoute(route);
}
