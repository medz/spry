import '../_constants.dart';
import '../types.dart';

Handler createChainHandler(Iterable<Handler> uses, Handler handler) {
  if (uses.isEmpty) return handler;
  return uses.fold<Handler>(
    handler,
    (next, current) => (event) {
      event.locals[kNext] = next;
      return current(event);
    },
  );
}
