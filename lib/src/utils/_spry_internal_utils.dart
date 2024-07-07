import '../event/event.dart';
import '../handler/handler.dart';
import '../http/response.dart';
import '../locals/_locals+get_or_set.dart';
import '../spry.dart';
import 'next.dart';

extension SpryInternalUtils on Spry {
  void addHandler(Handler handler) => handlers.add(handler);

  Future<Response> Function(Event) createHandle() {
    return handlers.reversed.fold(next, (effect, current) {
      return (event) {
        event.locals.set(next, effect);

        return current.handle(event);
      };
    });
  }
}

extension on Spry {
  static const handlersKey = #spry.app.handlers;

  List<Handler> get handlers {
    return locals.getOrSet<List<Handler>>(handlersKey, () => <Handler>[]);
  }
}
