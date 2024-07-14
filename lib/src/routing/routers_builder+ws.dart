// ignore_for_file: file_names

import 'dart:async';

import '../event.dart';
import '../handler.dart';
import '../http/headers.dart';
import '../http/response.dart';
import '../routing/routes_builder.dart';
import '../websocket/hooks.dart';
import '../websocket/message.dart';
import '../websocket/peer.dart';
import 'routes_builder+methods.dart';

extension RoutesBuilderWebSocket on RoutesBuilder {
  void ws(String path, Hooks hooks) {
    final handler = switch (hooks) {
      Handler handler => handler,
      _ => _HooksWithDefaultHandler(hooks),
    };

    get(path, handler);
  }
}

class _HooksWithDefaultHandler implements Handler, Hooks {
  const _HooksWithDefaultHandler(this.hooks);

  final Hooks hooks;

  @override
  FutureOr<Response> handle(Event event, Next next) {
    return Response(null, status: 426);
  }

  @override
  FutureOr<void> close(Peer peer, [int? code, String? reason]) {
    return hooks.close(peer, code, reason);
  }

  @override
  FutureOr<void> error(Peer peer, Object? error) {
    return hooks.error(peer, error);
  }

  @override
  FutureOr<void> message(Peer peer, Message message) {
    return hooks.message(peer, message);
  }

  @override
  FutureOr<void> open(Peer peer) {
    return hooks.open(peer);
  }

  @override
  FutureOr<Headers?> upgrade(Event event) {
    return hooks.upgrade(event);
  }
}
