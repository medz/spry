import 'dart:async';

import '../http/response.dart';
import 'event.dart';

abstract interface class Handler {
  FutureOr<Response> handle(Event event);
}
