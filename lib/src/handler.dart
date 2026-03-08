import 'dart:async';

import 'package:ht/ht.dart' show HttpMethod, Response;

import 'event.dart';

typedef Handler = FutureOr<Response> Function(Event event);
typedef RouteHandlers = Map<HttpMethod?, Handler>;

typedef ErrorHandler =
    FutureOr<Response> Function(
      Object error,
      StackTrace stackTrace,
      Event event,
    );
