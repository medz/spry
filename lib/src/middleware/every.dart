import '../middleware.dart';

/// Creates middleware that runs the provided middleware in order.
Middleware every(List<Middleware> middlewares) {
  return (event, next) {
    Next current = next;

    for (final middleware in middlewares.reversed) {
      final previous = current;
      current = () async => await middleware(event, previous);
    }

    return current();
  };
}
