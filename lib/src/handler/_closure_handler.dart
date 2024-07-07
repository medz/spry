import 'dart:async';

import '../event/event.dart';
import '../event/event+set_headers.dart';
import '../http/response.dart';
import '../locals/locals+get_or_null.dart';
import '../utils/next.dart';
import 'handler.dart';

final class ClosureHandler<T> implements Handler {
  const ClosureHandler(this.closure);

  final FutureOr<T> Function(Event) closure;

  @override
  Future<Response> handle(Event event) async {
    final headers = event.locals
        .getOrNull<Map<String, String>>(EventSetHeaders.kResponsibleHeaders);

    return switch (await closure(event)) {
      Response response => response,
      // TODO
      _ => next(event),
    };
  }
}
