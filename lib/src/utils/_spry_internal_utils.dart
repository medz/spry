import '../event/event.dart';
import '../handler/handler.dart';
import '../http/response.dart';
import '../locals/_locals+get_or_set.dart';
import '../spry.dart';
import 'next.dart';

extension SpryInternalUtils on Spry {
  static const handlersKey = #spry.app.handlers;

  List<Handler> get handlers {
    return locals.getOrSet<List<Handler>>(handlersKey, () => <Handler>[]);
  }

  Future<Response> Function(Handler, Event) createHandleWith() {
    return handlers.reversed.fold(
      (handler, event) => handler.handle(event),
      (effect, current) => (handler, event) {
        event.locals.set(next, (event) => effect(handler, event));

        return current.handle(event);
      },
    );
  }
}
