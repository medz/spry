import 'dart:async';

import '../http/responder.dart';
import '../polyfills/standard_web_polyfills.dart';
import '../request/request_event.dart';

abstract interface class Middleware {
  FutureOr<Response> respond(RequestEvent request, Responder next);
}

extension MiddlewareMakeResponder on Middleware {
  Responder makeResponder(Responder responder) =>
      _MiddlewareResponder(this, responder);
}

extension IterableMiddlewareMakeResponder on Iterable<Middleware> {
  Responder makeResponder(Responder responder) => toList().reversed.fold(
        responder,
        (responder, middleware) => middleware.makeResponder(responder),
      );
}

class _MiddlewareResponder implements Responder {
  final Responder responder;
  final Middleware middleware;

  _MiddlewareResponder(this.middleware, this.responder);

  @override
  FutureOr<Response> respond(RequestEvent event) =>
      middleware.respond(event, responder);
}
