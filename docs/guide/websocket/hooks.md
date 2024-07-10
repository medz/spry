---
title: WebSocket → Hooks
description: Using WebSocket hooks API, you can define a WebSocket server that works across runtimes with same synax.
---

# Hooks

Using WebSocket hooks API, you can define a WebSocket server that works across runtimes with same synax.

---

Spry WebSocket provides a cross-platform API to define WebSocket servers. An implementation with these hooks works across runtimes without needing you to go into details of any of them (while you always have the power to control low-level hooks). You can only define the life-cycle hooks that you only need and only those will be called on runtime.

::: warning
Spry WebSocket API is still under development and can change.
:::

```dart
import 'package:spry/websocket.dart';

class MyHooks implements Hooks {
  @override
  FutureOr fallback(Event event) {
    // If the platform does not support WebSocket or the upgrade fails,
    // it will be called.
    print('[ws] Not support.');
    return const Response(null, status: 426);
  }

  @override
  FutureOr<void> onClose(Peer peer, {int? code, String? reason}) {
    // Received a hook from a connected client or actively closed the websocket
    // call on the server side.
    print('[ws] close');
  }

  @override
  FutureOr<void> onError(Peer peer, error) {
    // Hook for errors from the server side.
    print('[ws] error: ${Error.safeToString(error)}');
  }

  @override
  FutureOr<void> onMessage(Peer peer, Message message) {
    // Hook when receiving messages from connected clients.
    final text = message.text();
    print('[ws] message: $text');

    if (text.contains('ping')) {
      peer.sendText('pong');
    }
  }

  @override
  FutureOr<CreatePeerOptions> onUpgrade(Event event) {
    // Called when upgrading request to WebSocket
    return CreatePeerOptions(...);
  }
}
```
