// ignore_for_file: file_names

import 'package:webfetch/webfetch.dart';

import '../application.dart';
import '../request/request_event.dart';
import 'responders.dart';

extension Application$Responder on Application {
  /// Returns [Responders] configuration instance for this application.
  Responders get responder {
    final existing = container.get<Responders>();
    if (existing != null) return existing;

    final responders = Responders(this);
    container.set(responders);

    // Set default responder.
    responders.use(Responders.normal);

    return responders;
  }

  /// Respond to a request.
  Future<Response> respond(RequestEvent event) async =>
      responder.current.respond(event);
}
