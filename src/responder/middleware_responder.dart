import 'dart:async';

import 'package:webfetch/webfetch.dart';

import '../middleware/middleware.dart';
import '../request/request_event.dart';
import 'responder.dart';

extension MiddlewareStackMakeResponder on Iterable<Middleware> {
  Responder makeResponder(Responder responder) =>
      fold(responder, MiddlewareResponder.new);
}

extension MiddlewareMakeResponder on Middleware {
  Responder makeResponder(Responder responder) =>
      MiddlewareResponder(responder, this);
}

class MiddlewareResponder implements Responder {
  final Responder responder;
  final Middleware middleware;

  const MiddlewareResponder(this.responder, this.middleware);

  @override
  FutureOr<Response> respond(RequestEvent event) {
    return middleware.respond(event, responder);
  }
}
