import 'dart:io';

import 'application.dart';
import 'polyfills/standard_web_polyfills.dart';
import 'request/request_event.dart';
import 'responder/application_responder.dart';

extension Serve on Application {
  /// Start a HTTP server and listen for incoming requests.
  Future<void> serve() async {
    final server = await HttpServer.bind('127.0.0.1', 8080);
    await for (final request in server) {
      final cookies = <Cookie>[];
      final event = RequestEvent(
        request: request,
        cookies: cookies,
        application: this,
      );

      final response = await responder.respond(event);
      await response.makeFor(request.response);

      request.cookies.addAll(cookies);
      await request.response.close();
    }
  }
}

extension on Response {
  Future makeFor(HttpResponse response) async {
    response.addStream(body);
  }
}
