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

/// Websocket peer.
abstract interface class Peer implements Event {
  /// The peer ready state.
  ReadyState get readyState;

  /// The peer protocol.
  ///
  /// TODO all adapter support, current only `dart:io`
  String? get protocol;

  /// Returns the peer extensions.
  String get extensions;

  /// Send a message.
  void send(Message message, [bool? compress]);

  /// Cloese the websocket.
  Future<void> close([int? code, String? reason]);
}

/// Spry websocket hooks.
abstract interface class Hooks {
  /// Hooks for websocket opened.
  FutureOr<void> open(Peer peer);

  /// Hooks for websocet close.
  FutureOr<void> close(Peer peer, [int? code, String? reason]);

  /// Hooks for websocket error.
  FutureOr<void> error(Peer peer, Object? error);

  /// Hooks for websocket message.
  FutureOr<void> message(Peer peer, Message message);
}

/// Websocket Upgrade handle.
typedef UpgradeHandle = FutureOr<bool> Function(Hooks);

/// Upgrade request event to websocket.
Future<bool> upgrade(Event event, Hooks hooks) async {
  final handle = event.get(#spry.ws.on_upgrade);
  if (handle is UpgradeHandle) {
    return await handle(hooks);
  }

  return false;
}

/// The [ws] extension.
extension RoutesWS on Routes {
  /// Register a websocket handler with [hooks].
  void ws<T>(String path, Hooks hooks, [Handler<T>? fallback]) {
    return get(path, (event) async {
      if (await upgrade(event, hooks)) {
        return Response(null, status: 101);
      }

      return fallback?.call(event) ?? Response(null, status: 426);
    });
  }
}

/// Define a [Hooks].
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
