/// This library implements support for the 'dart: io' platform.
library spry.platform.io;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'spry.dart';
import 'websocket.dart' hide CompressionOptions;

const _kUpgradedWebSocket = #spry.io.upgraded.websocket;

/// `dart:io` platform.
class IOPlatform extends Platform<HttpRequest, void>
    with WebSocketPlatform<HttpRequest, void> {
  const IOPlatform();

  @override
  Stream<Uint8List>? getRequestBody(Event event, HttpRequest request) {
    return request;
  }

  @override
  Headers getRequestHeaders(Event event, HttpRequest request) {
    final builder = HeadersBuilder();
    request.headers.forEach((name, values) {
      for (final value in values) {
        builder.add(name, value);
      }
    });

    return builder.toHeaders();
  }

  @override
  String getRequestMethod(Event event, HttpRequest request) {
    return request.method;
  }

  @override
  Uri getRequestURI(Event event, HttpRequest request) {
    return request.requestedUri;
  }

  @override
  String getClientAddress(Event event, HttpRequest request) {
    if (request.connectionInfo != null) {
      return '${request.connectionInfo?.remoteAddress.host}:${request.connectionInfo?.remotePort}';
    }

    return '';
  }

  @override
  Future<void> respond(
      Event event, HttpRequest request, Response response) async {
    if (event.locals.getOrNull(_kUpgradedWebSocket) == true) {
      return;
    }

    final httpResponse = request.response;
    httpResponse.statusCode = response.status;
    httpResponse.reasonPhrase = response.statusText;

    for (final (name, value) in response.headers) {
      httpResponse.headers.add(name, value);
    }

    final body = response.body;
    if (body != null) {
      await httpResponse.addStream(body);
    }

    await httpResponse.close();
  }

  @override
  websocket(Event event, HttpRequest request, Hooks hooks) async {
    if (event.locals.getOrNull(_kUpgradedWebSocket) == true) {
      throw HttpException('The current request has been upgraded to WebSocket',
          uri: event.uri);
    } else if (!WebSocketTransformer.isUpgradeRequest(request)) {
      return hooks.fallback(event);
    }

    final response = request.response;
    final options = await hooks.onUpgrade(event);
    for (final (name, value) in options.headers) {
      response.headers.add(name, value);
    }

    final websocket = await WebSocketTransformer.upgrade(
      request,
      compression: options.ioCompressionOptions,
      protocolSelector: _createProtocolSelector(options.protocols),
    );
    final peer = _IOPeer(event, websocket);

    websocket.listen(
      (payload) async {
        final message = switch (payload) {
          Uint8List bytes => Message.bytes(bytes),
          List<int> bytes => Message.bytes(Uint8List.fromList(bytes)),
          String text => Message.text(text),
          _ => throw WebSocketException('Unsupported payload message.'),
        };

        return hooks.onMessage(peer, message);
      },
      onError: (error) => hooks.onError(peer, error),
      onDone: () => hooks.onClose(peer,
          code: websocket.closeCode, reason: websocket.closeReason),
    );

    event.locals.set(_kUpgradedWebSocket, true);
  }

  static Future<String> Function(Iterable<String>)? _createProtocolSelector(
      Iterable<String>? supportedProtocols) {
    if (supportedProtocols == null || supportedProtocols.isEmpty) {
      return null;
    }

    final normalizedSupportedProtocols =
        supportedProtocols.map((e) => e.trim().toLowerCase());

    return (protocols) async {
      for (final protocol in protocols) {
        if (normalizedSupportedProtocols.contains(protocol)) {
          return protocol;
        }
      }

      throw WebSocketException('Unsupported WebSocket protocol');
    };
  }
}

extension on CreatePeerOptions {
  CompressionOptions get ioCompressionOptions {
    return CompressionOptions(
      enabled: compression.enabled,
      clientMaxWindowBits: compression.clientMaxWindowBits,
      serverMaxWindowBits: compression.serverMaxWindowBits,
      clientNoContextTakeover: compression.clientNoContextTakeover,
      serverNoContextTakeover: compression.serverNoContextTakeover,
    );
  }
}

class _IOPeer implements Peer {
  const _IOPeer(this.event, this.websocket);

  final Event event;
  final WebSocket websocket;

  @override
  Locals get locals => event.locals;

  @override
  ReadyState get readyState => ReadyState(websocket.readyState);

  @override
  Request get request => event.request;

  @override
  void send(Uint8List message) {
    websocket.add(message);
  }

  @override
  void sendText(String message) {
    websocket.add(message);
  }

  @override
  Future close([int? code, String? reason]) {
    return websocket.close(code, reason);
  }

  @override
  String get extensions => websocket.extensions;

  @override
  String? get protocol => websocket.protocol;
}
