// ignore_for_file: file_names

import 'dart:async';

import 'event/event.dart';
import 'handler/closure_handler.dart';
import 'handler/handler.dart';
import 'http/response.dart';
import 'locals/locals+get_or_null.dart';
import 'spry.dart';

extension SpryFallback on Spry {
  void fallback<T>(FutureOr<T> Function(Event event) closure) {
    locals.set<Handler>(#spry.app.fallback, ClosureHandler<T>(closure));
  }

  Handler getFallback() {
    return switch (locals.getOrNull<Handler>(#spry.app.fallback)) {
      Handler handler => handler,
      _ => const _DefaultFallbackHandler(),
    };
  }
}

abstract final class _FallbackHandler implements Handler {
  const _FallbackHandler();
}

final class _DefaultFallbackHandler extends _FallbackHandler {
  const _DefaultFallbackHandler();

  @override
  Future<Response> handle(Event event) async {
    return Response.text('Not Found.', status: 404);
  }
}
