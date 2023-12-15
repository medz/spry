import 'dart:async';

import '../polyfills/standard_web_polyfills.dart';
import '../request/request_event.dart';

abstract interface class Responder {
  FutureOr<Response> respond(RequestEvent event);
}
