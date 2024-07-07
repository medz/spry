// ignore_for_file: file_names

import 'dart:async';

import 'package:spry/src/http/response.dart';

import 'event/event.dart';
import 'handler/_closure_handler.dart';
import 'handler/handler.dart';
import 'locals/locals+get_or_null.dart';
import 'spry.dart';

extension SpryFallback on Spry {
  void fallback<T>(FutureOr<T> Function(Event event) closure) {
    locals.set(_FailbackHandler, ClosureHandler<T>(closure));
  }

  Handler getFallback() {
    return switch (locals.getOrNull<Handler>(_FailbackHandler)) {
      Handler handler => handler,
      _ => const _DefaultFailbackHandler(),
    };
  }
}

abstract final class _FailbackHandler implements Handler {
  const _FailbackHandler();
}

final class _DefaultFailbackHandler extends _FailbackHandler {
  const _DefaultFailbackHandler();

  @override
  Future<Response> handle(Event event) {
    // TODO: implement handle
    throw UnimplementedError();
  }
}
