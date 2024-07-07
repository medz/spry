import 'dart:async';

import '../event/event.dart';
import '../http/response.dart';
import '../utils/next.dart';
import 'handler.dart';

final class ClosureHandler<T> implements Handler {
  const ClosureHandler(this.closure);

  final FutureOr<T> Function(Event) closure;

  @override
  Future<Response> handle(Event event) async {
    return switch (await closure(event)) {
      Response response => response,
      _ => next(event),
    };
  }
}
