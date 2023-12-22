import 'dart:async';

import 'package:webfetch/webfetch.dart';

import '../middleware/spry_middleware_props.dart';
import '../request/request_event.dart';
import '../routing/spry_routes_props.dart';
import '../spry.dart';
import 'default_responder.dart';
import 'responder.dart';

class Responders {
  static Responder normal(Spry application) => DefaultResponder(
      routes: application.routes, middleware: application.middleware);

  /// Internal application.
  final Spry _application;

  /// Internal responder factory
  Responder Function(Spry application)? _factory;

  /// Returns the currenr responder.
  Responder get current {
    if (_factory == null) {
      throw StateError(
        'No responder configured. Configure with app.responder.use(...).',
      );
    }

    // If Responder is already set, return it.
    final existing = _application.container.get<Responder>();
    if (existing != null) return existing;

    // Otherwise, create a new responder.
    final responder = _factory!(_application);
    _application.container.set<Responder>(responder);

    return responder;
  }

  /// Use a new responder.
  void use(Responder Function(Spry application) factory) {
    _factory = factory;

    // Clear existing responder.
    _application.container.remove<Responder>();
  }

  Responders(Spry application) : _application = application;
}

extension SpryResponderProp on Spry {
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
  FutureOr<Response> respond(RequestEvent event) =>
      responder.current.respond(event);
}
