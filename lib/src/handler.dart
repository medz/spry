import 'dart:async';

import 'package:ht/ht.dart';

import 'event.dart';

typedef Handler = FutureOr<Response> Function(Event event);
typedef RouteHandlers = Map<String?, Handler>;

typedef ErrorHandler =
    FutureOr<Response> Function(
      Object error,
      StackTrace stackTrace,
      Event event,
    );
