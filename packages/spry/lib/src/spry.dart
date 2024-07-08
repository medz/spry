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
    final appLocals = AppLocals();
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
    appLocals.set(Spry, app);

    return app;
  }

  final Locals locals;
  final Router<Handler> router;

  @override
  void addRoute(String method, String route, Handler handler) {
    router.register('${method.toUpperCase()}/$route', handler);
  }
}
