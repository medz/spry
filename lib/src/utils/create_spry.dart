import 'package:routingkit/routingkit.dart';

import '../types.dart';

/// Creates a new [Spry] application.
Spry createSpry({Router<Handler>? router, Iterable<Handler>? stack}) {
  return _SpryImpl(
    router: switch (router) {
      Router<Handler> router => router,
      _ => createRouter<Handler>(),
    },
    stack: [...?stack],
  );
}

class _SpryImpl implements Spry {
  const _SpryImpl({required this.router, required this.stack});

  @override
  final Router<Handler> router;

  @override
  final List<Handler> stack;

  @override
  void on<T>(String method, String path, Handler<T> handler) {
    router.add(method, path, handler);
  }

  @override
  void use<T>(Handler<T> handler) {
    stack.add(handler);
  }
}
