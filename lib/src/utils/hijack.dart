import 'dart:async';
import 'dart:typed_data';

import '../types.dart';
import 'create_error.dart';

const _hijackerMark = #spry.request.hijacker;

typedef Hijacker = FutureOr<void> Function(
  Stream<Uint8List> stream,
  Sink<Uint8List> sink,
);

typedef FailHijack = FutureOr<void> Function();

/// Whether the request has been hijacked.
bool canHijacked(Event event) => event.locals[_hijackerMark] is Hijacker;

void hijack(Event event, Hijacker hijacker) async {
  if (canHijacked(event)) {
    throw createError("This request has already been hijacked.");
  }

  event.locals[_hijackerMark] = hijacker;
}

void onHijack() {}

Hijacker useHijecker(Event event) {
  return switch (event.locals[_hijackerMark]) {
    Hijacker hijacker => hijacker,
    _ => throw createError("This request not hijacked."),
  };
}
