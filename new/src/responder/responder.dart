import 'dart:async';

import '../request/request.dart';
import '../response/response.dart';

abstract interface class Responder {
  FutureOr<Response> respond(Request request);
}
