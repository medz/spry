import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import '_internal/application+factory.dart';
import '_internal/map+value_of.dart';
import 'routing/route.dart';
import 'routing/routes.dart';
import 'routing/routes_builder.dart';

class Application implements RoutesBuilder {
  /// Spry application version.
  static const version = '3.2.2';

  /// Returns application binded server.
  late final HttpServer server;

  /// Returns application locals.
  late final Map locals;

  /// Creates a new Spry application with the given [server].
  ///
  /// If [locals] is provided, it will be created a new empty map.
  ///
  /// ```dart
  /// main() async {
  ///   final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  ///   final app = Application(server);
  /// }
  Application(this.server, {Map? locals}) {
    this.locals = locals ?? {};
    this.locals[#spry.server.initialized] = true;

    poweredBy = 'Spry/$version';
  }

  /// Creates a new Spry application with late initialization of [server].
  ///
  /// ```dart
  /// final app = Application.late();
  ///
  /// main() async {
  ///   ...
  ///   await app.run(port: 3000);
  /// }
  /// ```
  ///
  /// **NOTE**: This contructor will create simple http server, You must use
  /// `app.run()` to start the server.
  Application.late([Map? locals]) {
    this.locals = locals ?? {};
    this.locals[#spry.server.initialized] = false;
  }

  /// Creates a new Spry application with the given [factory].
  Application.factory(ServerFactory factory) {
    locals = {};
    locals[#spry.server.initialized] = false;
    locals[#spry.server.factory] = factory;
  }

  /// Simple create application factory.
  static Future<Application> create({
    required int port,
    dynamic address,
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    final server = await HttpServer.bind(
        address ?? InternetAddress.loopbackIPv4, port,
        backlog: backlog, v6Only: v6Only, shared: shared);
    return Application(server);
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

  /// Returns spry application default `x-powered-by` header value.
  String? get poweredBy => locals[#spry.powered_by]?.toString();

  /// Sets spry application default `x-powered-by` header value.
  set poweredBy(String? value) {
    locals[#spry.powered_by] = value;
    if (locals[#spry.server.initialized] == true) {
      if (value == null) {
        return server.defaultResponseHeaders.removeAll('x-powered-by');
      }

      server.defaultResponseHeaders.set('x-powered-by', value);
    }
  }

  @override
  void addRoute<T>(Route<T> route) => routes.addRoute(route);
}
