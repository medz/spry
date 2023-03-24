import 'dart:async';
import 'dart:io';

import 'package:spry/spry.dart';
import 'package:stream_channel/stream_channel.dart';

import 'websocket_channel.dart';

/// WebSocket connected callback.
///
/// The [WebSocketChannel] is a wrapper around a [StreamChannel] that
/// provides a convenient API for sending and receiving WebSocket messages.
typedef WebSocketConnectedCallback = FutureOr<void> Function(
  Context context,
  WebSocketChannel channel,
);

/// Spry WebSocket handler.
///
/// The [SpryWebSocket] is a [Handler] that handles web socket connections.
class SpryWebSocket {
  /// Creates a new [SpryWebSocket].
  ///
  /// - The [handler] is the web socket handler, it is called when a web socket
  /// connection is established.
  /// - The [protocols] is the web socket handshake protocols.
  /// - The [pingInterval] see [WebSocketChannel.pingInterval].
  /// - The [fallback] is the web socket fallback handler, If the [Request] is not
  /// a web socket connection, then it will be handled by the [fallback].
  const SpryWebSocket(
    this.onConnection, {
    this.protocols,
    this.pingInterval,
    this.fallback,
  });

  /// Web socket handshake protocols.
  final Iterable<String>? protocols;

  /// [pingInterval] controls the interval for sending ping signals. If a ping
  /// message is not answered by a pong message from the peer, the WebSocket is
  /// assumed disconnected and the connection is closed with a `goingAway` close
  /// code. When a ping signal is sent, the pong message must be received within
  /// [pingInterval]. It defaults to `null`, indicating that ping messages are
  /// disabled.
  final Duration? pingInterval;

  /// The WebSocket connected callback.
  final WebSocketConnectedCallback onConnection;

  /// Web socket fallback handler.
  ///
  /// Used to detect socket connection if it is not a web socket connection,
  /// then it will be handled by the [fallback].
  final Handler? fallback;

  /// Coverts the [WebSocket] to a [Handler].
  Future<void> call(Context context) async {
    final request = context.request;
    if (!isWebSocketProtocolConnection(request)) {
      return fallback?.call(context) ?? _defaultFallback(context);
    }

    // validate protocol and web socket version
    _validateProtocol(request);

    final signatureKey = getWebSocketSignatureKeyOrThrow(request);
    final socket = await _detachSocket(context);

    // Gets the web socket sink and adds handshake headers.
    final sink = context.app.encoding.encoder.startChunkedConversion(socket)
      ..add(
        'HTTP/1.1 101 Switching Protocols\r\n'
        'Upgrade: websocket\r\n'
        'Connection: Upgrade\r\n'
        'Sec-WebSocket-Accept: $signatureKey\r\n',
      );

    // Chooses the protocol.
    final protocol = _chooseProtocol(request);

    // If the protocol is not null, then add it to the response headers.
    if (protocol != null) {
      sink.add('Sec-WebSocket-Protocol: $protocol\r\n');
    }

    // If the app is powered by, then add it to the response headers.
    if (context.app.poweredBy != null) {
      sink.add('X-Powered-By: ${context.app.poweredBy}\r\n');
    }

    // Ends the web socket handshake.
    sink.add('\r\n');

    final streamChannel = StreamChannel(socket, socket);
    final webSocketChannel = WebSocketChannel(
      streamChannel,
      protocol: protocol,
      pingInterval: pingInterval,
      serverSide: true,
    );

    // Awaits for the web socket channel to be ready.
    await webSocketChannel.ready;

    // Calls the web socket handler.
    await onConnection(context, webSocketChannel);

    // Awaits for the web socket channel to be done.
    await socket.done;

    // Closes the web socket connection.
    //
    // Note: The connection has been closed, tell Spry not to do anything here.
    return context.response.close(onlyCloseConnection: true);
  }

  /// Chooses the protocol.
  String? _chooseProtocol(Request request) {
    final protocols = request.headers
        .value('sec-websocket-protocol')
        ?.trim()
        .split(',')
        .map((e) => e.trim());
    if (protocols == null) return null;

    final supportedProtocols =
        this.protocols?.map((e) => e.toLowerCase().trim()) ?? [];
    if (supportedProtocols.isEmpty) return null;

    for (final protocol in protocols) {
      if (supportedProtocols.contains(protocol.toLowerCase())) {
        return protocol;
      }
    }

    return null;
  }

  /// Detaches the socket from the [Context].
  Future<Socket> _detachSocket(Context context) async {
    final HttpResponse response = context[HttpResponse];
    final socket = await response.detachSocket(writeHeaders: false);

    // Set the socket default encoding
    socket.encoding = context.app.encoding;

    return socket;
  }

  /// Returns web socket signature key.
  ///
  /// If the [Request] does not contain the `Sec-WebSocket-Key` header,
  /// then it will throw a [SpryHttpException.badRequest].
  static String getWebSocketSignatureKeyOrThrow(Request request) {
    final key = request.headers.value('sec-websocket-key');
    if (key == null) {
      throw SpryHttpException.badRequest(
        message: 'Missing Sec-WebSocket-Key header.',
      );
    }

    return WebSocketChannel.signKey(key);
  }

  /// Validates the protocol and web socket version.
  void _validateProtocol(Request request) {
    if (request.protocolVersion != '1.1') {
      throw SpryHttpException.badRequest(
        message: 'Invalid HTTP protocol version ${request.protocolVersion}.'
            "Only HTTP/1.1 is supported.",
      );
    }

    final version = request.headers.value('sec-websocket-version');
    if (version == null) {
      throw SpryHttpException.badRequest(
        message: 'Missing Sec-WebSocket-Version header.',
      );
    } else if (version != '13') {
      throw SpryHttpException.badRequest(
        message: 'Unsupported WebSocket version $version.',
      );
    }
  }

  /// Whether it is a websocket protocol connection.
  static bool isWebSocketProtocolConnection(Request request) {
    final connection = request.headers.value('connection');
    final upgrade = request.headers.value('upgrade');

    return connection != null &&
        upgrade != null &&
        connection.toLowerCase() == 'upgrade' &&
        upgrade.toLowerCase() == 'websocket';
  }

  /// Default fallback handler.
  void _defaultFallback(Context context) => _notFound(context);

  /// Not found handler.
  Never _notFound(Context context) {
    throw SpryHttpException.notFound(
      message: 'Only websocket protocol is supported.',
    );
  }
}
