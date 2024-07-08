import 'dart:typed_data';

import '../event/event.dart';
import '../http/headers/headers.dart';
import '../http/response.dart';
import '../types.dart';
import '../websocket/compression_options.dart';

final class UpgradeWebSocketOptions {
  const UpgradeWebSocketOptions({
    required this.compression,
    required this.headers,
    this.supportedProtocols,
  });

  final CompressionOptions compression;
  final Headers headers;
  final Iterable<String>? supportedProtocols;
}

abstract interface class Platform<T, R> {
  String getRequestMethod(Event event, T request);
  Uri getRequestURI(Event event, T request);
  Headers getRequestHeaders(Event event, T request);
  Stream<Uint8List>? getRequestBody(Event event, T request);
  Future<WebSocket?> upgradeWebSocket(
      Event event, T request, UpgradeWebSocketOptions options);

  Future<R> respond(Event event, T request, Response response);
}
