import 'package:routingkit/routingkit.dart' as routingkit;

import '../../composable/get_context.dart';
import '../../composable/next.dart';
import '../../event.dart';
import '../../handler.dart';
import '../_routing_keys.dart';
import '../route.dart';
import '../router.dart';

Router createRouter() {
  final inner = routingkit.createRouter<Handler>();

  return _RouterImpl(inner);
}

typedef _HandleWith = Future<void> Function(Event, Handler);

final class _RouterImpl implements Router {
  _RouterImpl(this.inner);

  _HandleWith? handleWith;
  final handlerStack = <Handler>[];
  final routingkit.Router<Handler> inner;

  @override
  Future<void> handle(Event event) {
    final context = getContext(event);
    final result = switch (event.method) {
      'HEAD' => switch (inner.lookup('HEAD/${event.uri.path}')) {
          routingkit.Result result => result,
          _ => inner.lookup('GET/${event.uri.path}'),
        },
      String method => switch (inner.lookup('$method/${event.uri.path}')) {
          routingkit.Result result => result,
          _ => inner.lookup('$kAllMethod/${event.uri.path}'),
        },
    };

    if (result == null) {
      throw 111;
    }

    context.set(kRouter, inner);
    context.set(kParams, result.params);
    context.set(kRoute, _RouteImpl(result.route.split('/').skip(1).join('/')));

    return switch (handleWith) {
      _HandleWith handle => handle(event, result.value),
      _ => result.value.handle(event),
    };
  }

  @override
  void use(Handler handler) {
    handlerStack.add(handler);
    handleWith = handlerStack.reversed.fold<_HandleWith>(
      defaultRouterHandle,
      (child, current) => (event, handler) async {
        setNext(() => child(event, handler));

        return current.handle(event);
      },
    );
  }

  @override
  void on(String method, String route, Handler handler) {
    inner.register('${method.toUpperCase()}/$route', handler);
  }

  static Future<void> defaultRouterHandle(Event event, Handler handler) =>
      handler.handle(event);
}

final class _RouteImpl implements Route {
  const _RouteImpl(this.id);

  @override
  final String id;
}
