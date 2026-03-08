import 'dart:async';

import 'event.dart';

typedef Handler = FutureOr<Object?> Function(Event event);
typedef RouteHandlers = Map<String?, Handler>;

typedef ErrorHandler =
    FutureOr<Object?> Function(
      Object error,
      StackTrace stackTrace,
      Event event,
    );
