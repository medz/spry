import 'dart:async';

import '../event.dart';
import '../handler.dart';
import '../http/headers.dart';
import '../http/response.dart';
import '../websocket/hooks.dart';
import '../websocket/message.dart';
import '../websocket/peer.dart';

Hooks defineHooks({
  required FutureOr<void> Function(Peer peer, Message message) message,
  FutureOr<void> Function(Peer peer)? open,
  FutureOr<void> Function(Peer peer, [int? code, String? reason])? close,
  FutureOr<void> Function(Peer peer, Object? error)? error,
  FutureOr<Headers?> Function(Event event)? upgrade,
}) {
  return _DefinedHooks(
    onMessage: message,
    onOpen: open,
    onClose: close,
    onError: error,
    onUpgrade: upgrade,
  );
}

final class _DefinedHooks implements Hooks, Handler {
  const _DefinedHooks({
    required this.onMessage,
    this.onOpen,
    this.onClose,
    this.onError,
    this.onUpgrade,
  });

  final FutureOr<void> Function(Peer, Message) onMessage;
  final FutureOr<void> Function(Peer)? onOpen;
  final FutureOr<void> Function(Peer, [int?, String?])? onClose;
  final FutureOr<void> Function(Peer, Object?)? onError;
  final FutureOr<Headers?> Function(Event)? onUpgrade;

  @override
  FutureOr<void> close(Peer peer, [int? code, String? reason]) {
    return onClose?.call(peer, code, reason);
  }

  @override
  FutureOr<void> error(Peer peer, Object? error) {
    return onError?.call(peer, error);
  }

  @override
  FutureOr<void> message(Peer peer, Message message) {
    return onMessage(peer, message);
  }

  @override
  FutureOr<void> open(Peer peer) {
    return onOpen?.call(peer);
  }

  @override
  FutureOr<Headers?> upgrade(Event event) {
    return onUpgrade?.call(event);
  }

  @override
  FutureOr<Response> handle(Event event, Next next) {
    return Response(null, status: 426);
  }
}
