import 'dart:async';

import '../event/event.dart';
import '../http/response.dart';
import '../responsible/responsible.dart';
import '../utils/next.dart';
import 'handler.dart';

/// Implement a [Handler] that supports [Responsible] return values.
final class ClosureHandler<T> implements Handler {
  const ClosureHandler(FutureOr<T> Function(Event event) closure)
      : _closure = closure;

  final FutureOr<T> Function(Event) _closure;

  @override
  Future<Response> handle(Event event) async {
    return switch (await _closure(event)) {
      null => next(event),
      Response response => response,
      Responsible responsible => responsible.createResponse(event),
      Object value => Responsible.of(event, value).createResponse(event),
    };
  }
}
