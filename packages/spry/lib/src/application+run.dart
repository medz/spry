// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import '_internal/application+factory.dart';
import 'application.dart';
import 'application+listen.dart';

extension Application$Run on Application {
  /// Runs the spry application.
  Future<StreamSubscription<HttpRequest>> run({
    required int port,
    dynamic address,
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    if (factory != null) {
      logger.warning(
        'HTTP Server already initialized, you should should use `app.listen()`',
      );

      server = await factory!(this);
      locals[#spry.server.initialized] = true;

      return listen();
    } else if (locals[#spry.server.initialized] == true) {
      logger.warning(
        'HTTP Server already initialized, you should should use `app.listen()`',
      );
      return listen();
    }

    server = await HttpServer.bind(
        address ?? InternetAddress.loopbackIPv4, port,
        backlog: backlog, v6Only: v6Only, shared: shared);
    locals[#spry.server.initialized] = true;

    return listen();
  }
}
