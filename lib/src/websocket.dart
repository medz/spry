import 'package:ht/ht.dart' show Headers, Response;
import 'package:osrv/websocket.dart' show WebSocketHandler;

import 'errors.dart';
import 'event.dart';

/// Websocket controls and metadata for the active request event.
final class EventWebSocket {
  /// Creates a websocket view over the active request event.
  const EventWebSocket(this._event);

  final Event _event;

  /// Whether the active runtime family supports websocket upgrades.
  bool get isSupported => _event.context.capabilities.websocket;

  /// Whether the active request is a websocket upgrade attempt.
  bool get isUpgradeRequest =>
      _event.context.webSocket?.isUpgradeRequest ?? false;

  /// Requested websocket subprotocols from the client handshake.
  List<String> get requestedProtocols =>
      _event.context.webSocket?.requestedProtocols ?? const <String>[];

  /// Accepts the websocket upgrade for the current request.
  Response upgrade(WebSocketHandler handler, {String? protocol}) {
    if (_event.method != 'GET') {
      throw HTTPError(405, headers: Headers({'allow': 'GET'}));
    }

    if (!isSupported) {
      throw const HTTPError(
        501,
        body: 'WebSocket is not supported by this runtime.',
      );
    }

    final webSocket = _event.context.webSocket;
    if (webSocket == null || !webSocket.isUpgradeRequest) {
      throw const HTTPError(426, body: 'Upgrade Required');
    }

    return webSocket.accept(handler, protocol: protocol);
  }
}
