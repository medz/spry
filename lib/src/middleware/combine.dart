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
