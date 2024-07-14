import 'dart:async';

import 'package:spry/src/http/response.dart';

import '../event.dart';
import '../handler.dart';

Handler defineHandler<T>(FutureOr<T> Function(Event event) closure) {
  return _FinalClosureHandler(closure);
}

final class _FinalClosureHandler<T> implements Handler {
  const _FinalClosureHandler(this.closure);

  final FutureOr<T> Function(Event event) closure;

  @override
  FutureOr<Response> handle(Event event, Next next) async {
    // final result = await closure(event);

    return Response(null, status: 200);
  }
}
