import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'spry.dart';

/// WebSocket's ready state.
extension type const ReadyState(int code) implements int {
  /// Unknown ready state.
  static const unknown = ReadyState(-1);

  /// Connecting ready state.
  static const connecting = ReadyState(0);

  /// Open ready state.
  static const open = ReadyState(1);

  /// Closing ready state.
  static const closing = ReadyState(2);

  /// Closed ready state.
  static const closed = ReadyState(3);
}

/// WebSocket message,
class Message {
  const Message._(this.raw);

  /// Creates a [String] message.
  factory Message.text(String text) => Message._(text);

  /// Creates a [Uint8List] message.
  factory Message.bytes(Uint8List bytes) => Message._(bytes);

  /// Message raw data, Types: Uint8List or String
  final dynamic raw;

  /// Returns the message text.
  String text() {
    return switch (raw) {
      String value => value,
      _ => utf8.decode(raw),
    };
  }

  /// Returns the message bytes.
  Uint8List bytes() {
    return switch (raw) {
      Uint8List bytes => bytes,
      _ => utf8.encode(raw),
    };
  }
}

abstract interface class Peer implements Event {
  ReadyState get readyState;
  String? get protocol;
  String get extensions;
  void send(Message message);
  Future<void> close([int? code, String? reason]);
}

abstract interface class Hooks {
  FutureOr<Headers?> upgrade(Event event);
  FutureOr<void> open(Peer peer);
  FutureOr<void> close(Peer peer, [int? code, String? reason]);
  FutureOr<void> error(Peer peer, Object? error);
  FutureOr<void> message(Peer peer, Message message);
}

typedef UpgradeHandle = FutureOr<bool> Function(Hooks);

void onUpgrade(Event event, UpgradeHandle handle) {
  event.set(#spry.ws.on_upgrade, handle);
}

Future<bool> upgrade(Event event, Hooks hooks) async {
  final handle = event.get(#spry.ws.on_upgrade);
  if (handle is! UpgradeHandle) {
    return false;
  }

  return await handle(hooks);
}

extension SpryWS on Spry {
  void ws<T>(String path, Hooks hooks, [Handler<T>? fallback]) {
    on('get', path, (event) async {
      if (await upgrade(event, hooks)) {
        return Response(null, status: 101);
      }

      return fallback?.call(event) ?? Response(null, status: 426);
    });
  }
}

Hooks defineHooks({
  required FutureOr<void> Function(Peer peer, Message message) message,
  FutureOr<void> Function(Peer peer)? open,
  FutureOr<void> Function(Peer peer, [int? code, String? reason])? close,
  FutureOr<void> Function(Peer peer, Object? error)? error,
  FutureOr<Headers?> Function(Event event)? upgrade,
}) {
  return _DefinedHooks(
    onMessage: message,
    onOpen: open,
    onClose: close,
    onError: error,
    onUpgrade: upgrade,
  );
}

class _DefinedHooks implements Hooks {
  const _DefinedHooks({
    required this.onMessage,
    this.onClose,
    this.onOpen,
    this.onError,
    this.onUpgrade,
  });

  final FutureOr<void> Function(Peer, Message) onMessage;
  final FutureOr<void> Function(Peer)? onOpen;
  final FutureOr<void> Function(Peer, [int?, String?])? onClose;
  final FutureOr<void> Function(Peer, Object?)? onError;
  final FutureOr<Headers?> Function(Event)? onUpgrade;

  @override
  FutureOr<void> message(Peer peer, Message message) {
    return onMessage(peer, message);
  }

  @override
  FutureOr<void> close(Peer peer, [int? code, String? reason]) {
    return onClose?.call(peer, code, reason);
  }

  @override
  FutureOr<void> error(Peer peer, Object? error) {
    return onError?.call(peer, error);
  }

  @override
  FutureOr<void> open(Peer peer) {
    return onOpen?.call(peer);
  }

  @override
  FutureOr<Headers?> upgrade(Event event) {
    return onUpgrade?.call(event);
  }
}
