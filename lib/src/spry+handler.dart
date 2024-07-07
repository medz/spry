// ignore_for_file: file_names

import 'dart:async';

import 'event/event.dart';
import 'handler/_closure_handler.dart';
import 'handler/handler.dart';
import 'http/response.dart';
import 'locals/_locals+get_or_set.dart';
import 'utils/next.dart';
import 'spry.dart';

extension SpryHandler on Spry {
  Handler get handler {
    final closure = handlers.reversed.fold(next, (effect, current) {
      return (event) {
        event.locals.set(next, effect);

        return current.handle(event);
      };
    });

    return ClosureHandler(closure);
  }

  void use<T>(FutureOr<T> Function(Event event) closure) {
    handlers.add(ClosureHandler<T>(closure));
  }
}

extension on Spry {
  static const key = #spry.app.handlers;

  List<Handler> get handlers {
    return locals.getOrSet<List<Handler>>(key, () => <Handler>[]);
  }
}
