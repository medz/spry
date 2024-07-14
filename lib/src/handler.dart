import 'dart:async';

import 'event.dart';
import 'http/response.dart';

abstract interface class Handler {
  FutureOr<Response> handle(Event event);
}
