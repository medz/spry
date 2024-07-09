import '../constants.dart';
import 'handler/handler.dart';
import 'locals/locals.dart';
import 'routing/routes_builder.dart';
import 'types.dart';

class Spry implements RoutesBuilder {
  const Spry._({required this.locals, required this.router});

  factory Spry({
    final Map? locals,
    final Router<Handler>? router,
    final RouterDriver routerDriver = const RadixTrieRouterDriver(),
    final bool caseSensitive = false,
  }) {
    final appLocals = _AppLocals();
    if (locals != null && locals.isNotEmpty) {
      appLocals.locals.addAll(locals);
    }

    final app = Spry._(
      locals: appLocals,
      router: switch (router) {
        Router<Handler> router => router,
        _ => createRouter(driver: routerDriver, caseSensitive: caseSensitive)
      },
    );
    appLocals.set(kAppInstance, app);

    return app;
  }

  final Locals locals;
  final Router<Handler> router;

  @override
  void addRoute(String method, String route, Handler handler) {
    router.register('${method.toUpperCase()}/$route', handler);
  }
}

final class _AppLocals implements Locals {
  final Map locals = {};

  @override
  T get<T>(Object key) => locals[key];

  @override
  void set<T>(Object key, T value) {
    locals[key] = value;
  }

  @override
  void remove(Object key) {
    locals.remove(key);
  }
}
