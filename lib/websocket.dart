library spry.websocket;

import 'dart:async';
import 'dart:io';

import 'package:spry/spry.dart';

/// WebSocket ready on connected callback.
typedef WebSocketOnConnected = FutureOr<void> Function(WebSocket websocket);

/// WebSocket protocol selector.
typedef WebSocketProtocolSelector = String? Function(List<String> protocols);

/// A WebSocket handler for Spry framework.
///
/// This class is used to handle WebSocket connections.
class WebSocketHandler {
  const WebSocketHandler({
    required this.onConnected,
    this.fallback,
    this.protocolSelector,
    this.compression = CompressionOptions.compressionDefault,
  });

  /// Fallback handler.
  ///
  /// If the request is not a WebSocket request, this handler will be called.
  final Handler? fallback;

  /// The WebSocket connected handler.
  final WebSocketOnConnected onConnected;

  /// WebSocket protocol selector.
  final WebSocketProtocolSelector? protocolSelector;

  /// WebScoket compression options.
  final CompressionOptions compression;

  /// As the WebSocket handler cast to Spry [Handler].
  FutureOr<void> call(Context context) async {
    final request = _httpRequest(context);
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      return fallback?.call(context) ?? _defaultFallback();
    }

    final websocket = await WebSocketTransformer.upgrade(
      request,
      protocolSelector: protocolSelector,
      compression: compression,
    );

    return Future.value(onConnected(websocket)).then(
      (value) => websocket.done.then((_) => value),
    );
  }

  /// Default fallback handler.
  Never _defaultFallback() => throw SpryHttpException.notFound(
      message: 'Unsupported request for WebSocket.');

  /// Resolve the [HttpRequest] of the [Context].
  static HttpRequest _httpRequest(Context context) => context[HttpRequest];
}
