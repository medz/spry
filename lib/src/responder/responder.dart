import 'dart:async';

import '../event.dart';
import '../http/response.dart';

abstract interface class Responder {
  FutureOr<Response> respond(Event event);
}
