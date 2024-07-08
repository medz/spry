import 'dart:async';

import '../event/event.dart';
import '../http/response.dart';
import '../responsible/responsible.dart';
import '../utils/next.dart';
import 'handler.dart';

final class ClosureHandler<T> implements Handler {
  const ClosureHandler(this.closure);

  final FutureOr<T> Function(Event) closure;

  @override
  Future<Response> handle(Event event) async {
    return switch (await closure(event)) {
      null => next(event),
      Response response => response,
      Responsible responsible => responsible.createResponse(event),
      Object value => Responsible.of(event, value).createResponse(event),
    };
  }
}
