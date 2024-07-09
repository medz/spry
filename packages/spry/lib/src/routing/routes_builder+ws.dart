// ignore_for_file: file_names

import 'dart:async';

import '../../constants.dart';
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
    Iterable<String>? supportedProtocols,
  }) {
    all(route, (event) async {
      final raw = event.locals.get(kRawRequest);
      final platform = event.locals.get<Platform>(kPlatform);
      final options = UpgradeWebSocketOptions(
        compression: compression,
        supportedProtocols: supportedProtocols,
        headers: switch (await makeHeaders?.call(event)) {
          Headers headers => headers,
          _ => const Headers(),
        },
      );
      final websocket = await platform.upgradeWebSocket(event, raw, options);

      if (websocket == null) {
        if (fallback != null) {
          return fallback(event);
        }

        return Response(null, status: 426);
      }

      await closure(event, websocket);
    });
  }
}
