/// This library implements WebSockets support for Spry
library spry.websocket;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'constants.dart';
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

/// Peer object allows easily interacting with connected clients.
abstract interface class Peer implements Event {
  /// Returns websocket [ReadyState].
  ReadyState get readyState;

  /// Returns the websocket selected protocol.
  ///
  /// If server-side no configured protocols, the [protocol] value is null.
  String? get protocol;

  /// Returns the websocket cliend-side request extensions.
  String get extensions;

  /// Send a bytes [message] to the connected client
  void send(Uint8List message);

  /// Send a [String] message to the connected client.
  void sendText(String message);

  /// Close websocket connect.
  Future close([int? code, String? reason]);
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

/// Create [Peer] options.
class CreatePeerOptions {
  const CreatePeerOptions({
    required this.compression,
    required this.headers,
    this.protocols,
  });

  /// WebSocket compression options.
  final CompressionOptions compression;

  /// Response headers attached when upgrading websocket.
  final Headers headers;

  /// Define the protocols supported by server side.
  final Iterable<String>? protocols;
}

/// WebSocket platform interface.
///
/// Usually, it is used together with the Platform, and when implementing
/// the Spry [Platform] interface, if the platform supports WebSocket,
/// then you should use it.
///
/// ```dart
/// class MyPlatform extends Platform with WebSocketPlatform {
///     // ...
/// }
/// ```
mixin WebSocketPlatform<T, R> on Platform<T, R> {
  /// Upgrading websocket.
  ///
  /// The return value can be any data you need, for example, in the event
  /// of a failure, you can return a [Response] or the result of a fallback call.
  /// Due to the different contents returned by different platforms, the return
  /// value depends on your implementation.
  FutureOr websocket(Event event, T request, Hooks hooks);
}

/// WebSocket hooks interface.
///
/// It is used to standardize WebSocket events for various platforms.
abstract interface class Hooks {
  /// Called when upgrading request to WebSocket, returns [CreatePeerOptions].
  FutureOr<CreatePeerOptions> onUpgrade(Event event);

  /// Hook when receiving messages from connected clients.
  FutureOr<void> onMessage(Peer peer, Message message);

  /// Received a hook from a connected client or actively closed the websocket
  /// call on the server side.
  FutureOr<void> onClose(Peer peer, {int? code, String? reason});

  /// Hook for errors from the server side
  FutureOr<void> onError(Peer peer, dynamic error);

  /// When the request does not support upgrading or fails to upgrade,
  /// its return value is the same as that of a normal routing handler,
  /// which can be [Responsible] or [Response] supported data.
  FutureOr fallback(Event event);
}

/// Add the [ws] routing method to Spry [RoutesBuilder].
extension RoutesBuilderWS on RoutesBuilder {
  /// Register a websocket route.
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
