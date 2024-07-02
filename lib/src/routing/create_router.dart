import 'package:routingkit/routingkit.dart' as routingkit;

import '../composable/next.dart';
import '../create_stack_handler.dart';
import '../define_handler.dart';
import '../event.dart';
import '../handler.dart';
import 'router.dart';

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
    final (_, route) = inner.lookup('/');

    return switch ((route, handleWith)) {
      (Handler handler, _HandleWith handle) => handle(event, handler),
      (Handler handler, _) => handler.handle(event),
      _ => throw 000,
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

  static Future<void> defaultRouterHandle(Event event, Handler handler) =>
      handler.handle(event);
}
