import 'dart:async';

import '../event.dart';
import '../http/headers.dart';
import 'message.dart';
import 'peer.dart';

abstract interface class Hooks {
  FutureOr<Headers?> upgrade(Event event);
  FutureOr<void> open(Peer peer);
  FutureOr<void> message(Peer peer, Message message);
  FutureOr<void> close(Peer peer);
  FutureOr<void> error(Peer peer, Object? error);
}
