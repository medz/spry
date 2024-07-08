library spry.platform.io;

import 'dart:io' hide WebSocket;
import 'dart:io' as io show CompressionOptions;
import 'dart:typed_data';

import 'package:web_socket/io_web_socket.dart';

import 'spry.dart';

class IOPlatform implements Platform<HttpRequest, void> {
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
  Future<void> respond(
      Event event, HttpRequest request, Response response) async {
    final httpResponse = request.response;
    if (event.responded) {
      await httpResponse.close();
      return;
    }

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
  Future<WebSocket?> upgradeWebSocket(
      Event event, HttpRequest request, UpgradeWebSocketOptions options) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      return null;
    }

    final response = request.response;
    for (final (name, value) in options.headers) {
      response.headers.add(name, value);
    }

    final websocket = await WebSocketTransformer.upgrade(
      request,
      compression: options.ioCompressionOptions,
      protocolSelector: _createProtocolSelector(options.supportedProtocols),
    );

    return IOWebSocket.fromWebSocket(websocket);
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

extension on UpgradeWebSocketOptions {
  io.CompressionOptions get ioCompressionOptions {
    return io.CompressionOptions(
      enabled: compression.enabled,
      clientMaxWindowBits: compression.clientMaxWindowBits,
      serverMaxWindowBits: compression.serverMaxWindowBits,
      clientNoContextTakeover: compression.clientNoContextTakeover,
      serverNoContextTakeover: compression.serverNoContextTakeover,
    );
  }
}
