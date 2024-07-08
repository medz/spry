// ignore_for_file: file_names

import 'dart:async';

import '../_constants.dart';
import '../event/event.dart';
import '../http/headers/headers.dart';
import '../http/response.dart';
import '../platform/platform.dart';
import '../types.dart';
import '../websocket/compression_options.dart';
import 'routes_builder.dart';
import 'routes_builder+all.dart';

extension RoutesBuilderWS on RoutesBuilder {
  void ws(
    String route,
    FutureOr<void> Function(Event event, WebSocket ws) closure, {
    FutureOr Function(Event event)? fallback,
    CompressionOptions compression = const CompressionOptions(),
    FutureOr<Headers> Function(Event event)? makeHeaders,
    Iterable<String>? supportProtocols,
  }) {
    all(route, (event) async {
      final options = UpgradeWebSocketOptions(
        compression: compression,
        supportProtocols: supportProtocols ?? const [],
        headers: switch (await makeHeaders?.call(event)) {
          Headers headers => headers,
          _ => const Headers(),
        },
      );
      final webSocket = await event.platform
          .upgradeWebSocket(event, event.rawRequest, options);
      if (webSocket == null) {
        if (fallback != null) {
          return fallback(event);
        }

        return Response(null, status: 426);
      }

      await closure(event, webSocket);
    });
  }
}

extension on Event {
  get rawRequest => locals.get(kRawRequest);
  Platform get platform => locals.get<Platform>(Platform);
}
