import 'dart:async';

import 'package:ht/ht.dart' show Response;

import 'event.dart';

typedef Next = Future<Response> Function();
typedef Handler = FutureOr<Object?> Function(Event event);
typedef RouteHandlers = Map<String?, Handler>;
typedef Middleware = FutureOr<Response> Function(Event event, Next next);
typedef ErrorHandler =
    FutureOr<Object?> Function(
      Object error,
      StackTrace stackTrace,
      Event event,
    );
