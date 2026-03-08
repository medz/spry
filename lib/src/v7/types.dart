import 'dart:async';

import '../http/response.dart';
import 'event.dart';
import 'http_method.dart';

typedef Next = Future<Response> Function();
typedef Handler = FutureOr<Object?> Function(Event event);
typedef RouteHandlers = Map<HttpMethod, Handler>;
typedef Middleware = FutureOr<Response> Function(Event event, Next next);
typedef ErrorHandler =
    FutureOr<Object?> Function(Object error, StackTrace stack, Event event);
