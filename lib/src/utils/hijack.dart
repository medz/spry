import 'dart:async';
import 'dart:typed_data';

import '../types.dart';
import 'create_error.dart';

const _hijacked = #spry.can_hijack;
const _hijackHandler = #spry.hijack_handler;

typedef HijackCallback<T> = FutureOr<T> Function(
    Stream<Uint8List> stream, Sink<Uint8List> sink);
typedef HijackHandler<T extends Sink<Uint8List>, R> = FutureOr<R> Function(
    HijackCallback<R> fn);

/// Whether this request can be hijacked.
bool canHijack(Event event) => event.get(_hijacked) != true;

/// Register on hijack handler.
void onHijack<T extends Sink<Uint8List>, R>(
    Event event, HijackHandler<T, R> handler) {
  event.set(_hijackHandler, handler);
}

// Takes control of the underlying request socket.
Future<T> hijack<T>(Event event, HijackCallback<T> fn) async {
  if (!canHijack(event)) {
    throw createError('This request has already been hijacked.');
  }

  final handler = event.get<HijackHandler<Sink<Uint8List>, T>>(_hijackHandler);
  if (handler == null) {
    throw createError('This request can\'t be hijacked.');
  }

  return await handler(fn);
}
