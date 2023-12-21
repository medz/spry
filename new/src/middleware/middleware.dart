import 'package:webfetch/webfetch.dart';

import '../request/request_event.dart';
import '../responder/responder.dart';

abstract interface class Middleware {
  Future<Response> respond(RequestEvent event, Responder next);
}

extension MiddlewareMakeResponder on Middleware {
  Responder makeResponder(Responder responder) =>
      _MiddlewareResponder(this, responder);
}

extension IterableMiddlewareMakeResponder on Iterable<Middleware> {
  Responder makeResponder(Responder responder) {
    final reversed = switch (this) {
      List<Middleware>(reversed: final reversed) => reversed,
      _ => toList().reversed,
    };

    return reversed.fold(
      responder,
      (responder, middleware) => middleware.makeResponder(responder),
    );
  }
}

class _MiddlewareResponder implements Responder {
  final Responder responder;
  final Middleware middleware;

  _MiddlewareResponder(this.middleware, this.responder);

  @override
  Future<Response> respond(event) => middleware.respond(event, responder);
}
