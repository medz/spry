import 'package:routingkit/routingkit.dart';

import 'types.dart';

/// Creates a new [Spry] application.
Spry createSpry({RouterContext<Handler>? router, Iterable<Handler>? stack}) {
  return _SpryImpl(
    router: switch (router) {
      RouterContext<Handler> router => router,
      _ => createRouter<Handler>(),
    },
    stack: [...?stack],
  );
}

class _SpryImpl implements Spry {
  const _SpryImpl({required this.router, required this.stack});

  @override
  final RouterContext<Handler> router;

  @override
  final List<Handler> stack;

  @override
  void on<T>(String method, String path, Handler<T> handler) {
    addRoute(router, method, path, handler);
  }

  @override
  void use<T>(Handler<T> handler) {
    stack.add(handler);
  }
}
