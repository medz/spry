---
title: Advanced → WebSockets
description: Spry has built-in support for cross platform WebSocket
---

# WebSockets

{{ $frontmatter.description }}

---

Spry natively supports runtime agnostic WebSocket API.

**Example**:

```dart
import 'package:spry/ws.dart';

app.ws('/chat', defineHooks(
    message: (peer, message) {
        final text = message.text();
        print('[WS] message: ${text}');

        if (text == 'ping') {
            peer.send(Message.text('pong'));
        }
    }
));
```

## Hooks

Spry provides a cross-platform API to define WebSocket servers. An implementation with these hooks works across runtimes without needing you to go into details of any of them (while you always have the power to control low-level hooks). You can only define the life-cycle hooks that you only need and only those will be called on runtime.

```dart
final hooks = defineHooks(
    upgrade: (event) {
        final uri = useRequestURI(event);
        print('[WS] upgrading $uri');
    },
    open: (peer) {
        final address = getClientAddress(peer);
        print('[WS] open: $address');
    },
    message: (peer, message) {
        final text = message.text();
        print('[WS] message: ${text}');

        if (text == 'ping') {
            peer.send(Message.text('pong'));
        }
    },
    close: (peer, [int? code, String? reason]) {
        print('[WS] close($code) - ${reason}');
    },
    error: (peer, error) {
        print('[WS] error: $error');
    }
);
```

## Peer

Websocket hooks accept a peer instance as their first argument. You can use peer object to get information about each connected client or send a message to them.

::: tip
The `Peer` implements `Event` object.
:::

### `peer.readyState`

Client connection status (might be `-1`).

::: info
Read more [readyState in MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/readyState).
:::

### `peer.send`

Send a message to the connected client


### `peer.close`

Cloese the websocket.

## Message

On message hook, you receive a message object containing an incoming message from the client.

### `message.text()`

Get stringified text version of the message

### `message.bytes()`

Get the message bytes.
