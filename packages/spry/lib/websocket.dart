import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'constants.dart';
import 'spry.dart';

extension type const ReadyState(int code) implements int {
  static const unknown = ReadyState(-1);
  static const connecting = ReadyState(0);
  static const open = ReadyState(1);
  static const closing = ReadyState(2);
  static const closed = ReadyState(3);
}

abstract interface class Peer implements Event {
  ReadyState get readyState;
  String? get protocol;
  String get extensions;

  void send(Uint8List message);
  void sendText(String message);
  Future close([int? code, String? reason]);
}

class Message {
  const Message._(this.raw);

  factory Message.text(String text) => Message._(text);
  factory Message.bytes(Uint8List bytes) => Message._(bytes);

  final dynamic raw; // Uint8List or String

  String text() {
    return switch (raw) {
      String value => value,
      _ => utf8.decode(raw),
    };
  }

  Uint8List bytes() {
    return switch (raw) {
      Uint8List bytes => bytes,
      _ => utf8.encode(raw),
    };
  }
}

/// Options controlling compression in a [WebSocket].
///
/// A [CompressionOptions] instance can be passed to [WebSocket.connect], or
/// used in other similar places where [WebSocket] compression is configured.
///
/// In most cases the default [compressionDefault] is sufficient, but in some
/// situations, it might be desirable to use different compression parameters,
/// for example to preserve memory on small devices.
class CompressionOptions {
  const CompressionOptions(
      {this.clientNoContextTakeover = false,
      this.serverNoContextTakeover = false,
      this.clientMaxWindowBits,
      this.serverMaxWindowBits,
      this.enabled = true});

  /// Whether the client will reuse its compression instances.
  final bool clientNoContextTakeover;

  /// Whether the server will reuse its compression instances.
  final bool serverNoContextTakeover;

  /// The maximal window size bit count requested by the client.
  ///
  /// The windows size for the compression is always a power of two, so the
  /// number of bits precisely determines the window size.
  ///
  /// If set to `null`, the client has no preference, and the compression can
  /// use up to its default maximum window size of 15 bits depending on the
  /// server's preference.
  final int? clientMaxWindowBits;

  /// The maximal window size bit count requested by the server.
  ///
  /// The windows size for the compression is always a power of two, so the
  /// number of bits precisely determines the window size.
  ///
  /// If set to `null`, the server has no preference, and the compression can
  /// use up to its default maximum window size of 15 bits depending on the
  /// client's preference.
  final int? serverMaxWindowBits;

  /// Whether WebSocket compression is enabled.
  ///
  /// If not enabled, the remaining fields have no effect, and the
  /// [compressionOff] instance can, and should, be reused instead of creating a
  /// new instance with compression disabled.
  final bool enabled;
}

class CreatePeerOptions {
  const CreatePeerOptions({
    required this.compression,
    required this.headers,
    this.protocols,
  });

  final CompressionOptions compression;
  final Headers headers;
  final Iterable<String>? protocols;
}

abstract interface class WebSocketPlatform<T, R> {
  FutureOr websocket<V>(Event event, T request, Hooks hooks);
}

abstract interface class Hooks {
  FutureOr<CreatePeerOptions> onUpgrade(Event event);
  FutureOr<void> onMessage(Peer peer, Message message);
  FutureOr<void> onClose(Peer peer, {int? code, String? reason});
  FutureOr<void> onError(Peer peer, dynamic error);
  FutureOr fallback(Event event);
}

extension RoutesBuilderWS on RoutesBuilder {
  void ws(String route, Hooks hooks) {
    all(route, (event) async {
      final platform = event.locals.getOrNull<WebSocketPlatform>(kPlatform);
      if (platform == null) {
        return hooks.fallback(event);
      }

      final request = event.locals.get(kRawRequest);

      return platform.websocket(event, request, hooks);
    });
  }
}
