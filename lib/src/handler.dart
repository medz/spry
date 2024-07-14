import 'dart:async';

import 'event.dart';
import 'http/response.dart';

typedef Next = Future<Response> Function();

abstract interface class Handler {
  FutureOr<Response> handle(Event event, Next next);
}
