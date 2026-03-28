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

/// Selects which tracked error `some(...)` should throw after all candidates fail.
abstract interface class SomeErrorThrower {
  /// Creates a thrower that rethrows the first tracked error.
  factory SomeErrorThrower.first() => _BuiltSomeErrorThrower(true);

  /// Creates a thrower that rethrows the last tracked error.
  factory SomeErrorThrower.last() => _BuiltSomeErrorThrower(false);

  /// Tracks a failed candidate error.
  void track(Object error, StackTrace stackTrace);

  /// Throws the selected error after all candidates fail.
  Never throws();
}

final class _BuiltSomeErrorThrower implements SomeErrorThrower {
  _BuiltSomeErrorThrower(this.first);

  final bool first;
  final tracked = <(Object, StackTrace)>[];

  @override
  Never throws() {
    final (error, stackTrace) = first ? tracked.first : tracked.last;
    Error.throwWithStackTrace(error, stackTrace);
  }

  @override
  void track(Object error, StackTrace stackTrace) {
    tracked.add((error, stackTrace));
  }
}

/// Creates middleware that tries candidates in order until one succeeds.
Middleware some(
  Iterable<Middleware> middlewares, {

  /// Creates the error thrower for the active request.
  SomeErrorThrower Function()? createThrower,
}) {
  if (middlewares.isEmpty) {
    throw ArgumentError.value(middlewares, 'middlewares', 'Must not be empty.');
  }

  return (event, next) async {
    Future<Response>? result;
    Future<Response> sharedNext() => result ??= next();
    final thrower = createThrower?.call() ?? SomeErrorThrower.first();

    for (final middleware in middlewares) {
      try {
        return await middleware(event, sharedNext);
      } catch (error, stackTrace) {
        thrower.track(error, stackTrace);
      }
    }

    thrower.throws();
  };
}
