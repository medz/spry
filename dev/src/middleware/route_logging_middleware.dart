import 'dart:async';

import 'package:logging/logging.dart';

import '../http/responder.dart';
import '../polyfills/standard_web_polyfills.dart';
import '../request/request_event.dart';
import 'middleware.dart';

class RouteLoggingMiddleware implements Middleware {
  final Level level;

  const RouteLoggingMiddleware([this.level = Level.INFO]);

  @override
  FutureOr<Response> respond(RequestEvent event, Responder next) {
    event.logger.log(level, '${event.request.method} ${event.request.url}');

    return next.respond(event);
  }
}
