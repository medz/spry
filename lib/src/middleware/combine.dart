import 'package:ht/ht.dart' show Response;

import '../event.dart';
import '../middleware.dart';

/// Creates middleware that runs the provided middleware in order.
Middleware every(Iterable<Middleware> middlewares) {
  final pipeline = switch (middlewares) {
    List<Middleware>(:final reversed) => reversed,
    _ => List.of(middlewares, growable: false).reversed,
  };

  return (event, next) {
    Next current = next;
    for (final middleware in pipeline) {
      final prev = current;
      current = () async => middleware(event, prev);
    }

    return current();
  };
}

/// Creates middleware that skips [middleware] when [when] returns `true`.
Middleware except(Middleware middleware, bool Function(Event event) when) {
  return (event, next) {
    if (when(event)) return next();
    return middleware(event, next);
  };
}

/// Creates middleware that tries candidates in order until one succeeds.
Middleware some(Iterable<Middleware> middlewares) {
  final pipeline = switch (middlewares) {
    List<Middleware>() => middlewares,
    _ => List.of(middlewares, growable: false),
  };

  if (pipeline.isEmpty) {
    throw ArgumentError.value(middlewares, 'middlewares', 'Must not be empty.');
  }

  return (event, next) async {
    Future<Response>? nextResult;
    Object? lastError;
    StackTrace? lastStackTrace;

    Future<Response> sharedNext() {
      return nextResult ??= next();
    }

    for (final middleware in pipeline) {
      try {
        return await middleware(event, sharedNext);
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
      }
    }

    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  };
}
