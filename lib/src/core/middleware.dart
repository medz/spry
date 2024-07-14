import 'dart:async';

import '../http/response.dart';
import 'event.dart';

typedef Next = FutureOr<Response> Function();

abstract interface class Middleware {
  FutureOr<Response> process(Event event, Next next);
}
