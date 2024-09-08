import 'dart:async';
import 'dart:typed_data';

import '../types.dart';
import 'create_error.dart';

const _hijacked = #spry.can_hijack;
const _hijackHandler = #spry.hijack_handler;

typedef HijackCallback = FutureOr<void> Function(
    Stream<Uint8List> stream, Sink<Uint8List> sink);
typedef HijackHandler = FutureOr<void> Function(HijackCallback fn);

/// Whether this request can be hijacked.
bool canHijack(Event event) => event.get(_hijacked) != true;

/// Register on hijack handler.
void onHijack(Event event, HijackHandler handler) {
  event.set(_hijackHandler, handler);
}

// Takes control of the underlying request socket.
Future<void> hijack(Event event, HijackCallback fn) async {
  if (!canHijack(event)) {
    throw createError('This request has already been hijacked.');
  }

  final handler = event.get<HijackHandler>(_hijackHandler);
  if (handler == null) {
    throw createError('This request can\'t be hijacked.');
  }

  event.set(_hijacked, true);
  await handler(fn);
}
