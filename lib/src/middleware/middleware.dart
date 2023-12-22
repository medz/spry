import 'dart:async';

import 'package:webfetch/webfetch.dart';

import '../request/request_event.dart';
import '../responder/responder.dart';

abstract interface class Middleware {
  FutureOr<Response> respond(RequestEvent event, Responder next);
}
