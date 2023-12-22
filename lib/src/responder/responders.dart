import 'dart:async';

import 'package:logging/logging.dart';
import 'package:webfetch/webfetch.dart';

import '../core/core.dart';
import '../middleware/spry_middleware_props.dart';
import '../request/request_event.dart';
import '../routing/spry_routes_props.dart';
import '../spry.dart';
import 'default_responder.dart';
import 'responder.dart';

class Responders {
  /// Internal application.
  final Spry _application;

  /// Internal responder configuration.
  Responder? _responder;

  /// Internal logger.
  final Logger _logger = Logger('spry.responder');

  /// Returns the currenr responder.
  Responder get current {
    if (_responder != null) return _responder!;
    _logger.info('Creating default responder.');

    return _responder = DefaultResponder(
      routes: _application.routes,
      middleware: _application.middleware,
    );
  }

  /// Use a new responder.
  void use(Responder Function(Spry application) factory) {
    if (_application.running != null) {
      _logger.severe('Cannot use responder while application is running.');
      return;
    }

    _responder = factory(_application);
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

    return responders;
  }

  /// Respond to a request.
  FutureOr<Response> respond(RequestEvent event) =>
      responder.current.respond(event);
}
