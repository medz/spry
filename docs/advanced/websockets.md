---
title: Advanced → Websockets
---

# WebSockets

[WebSocket](https://en.wikipedia.org/wiki/WebSocket) is a protocol that allows for persistent, full-duplex communication between a client and server. This is useful for applications that require real-time updates, such as chat rooms, news feeds, and more.

Spry allows you to create `dart:io` based WebSocket servers to handle messages. You can use the routing API to add WebSocket endpoints to an existing Spry Application.

```dart
import 'package:spry/spry.dart';

app.ws("echo", (ws, request) {
    print("WebSocket connected");

    ...
});
```

WebSocket routing can be divided and registered with middleware through `app.group`, etc. just like ordinary routing.

## Message encoding

`WebSocket` comes from `dart:io`, the messages it sends and receives have `dynamic` type signature, but the actual situation is that Dart does not support `Union` type, so its correct message signature should be `List<int> | String `.

::: tip

See [`dart:io` → `WebSocket`](https://api.dart.dev/stable/dart-io/WebSocket-class.html) for more information.

:::

## Listening for messages

Because `app.ws` accepts a `FutureOr<void>` callback, you can use `await` to wait for messages.

```dart
app.ws("echo", (ws, request) async {
    print("WebSocket connected");

    await for (final message in ws) {
        print("Received: $message");
    }
});
```

Of course, you can also use `ws.listen` to listen for messages.

```dart
app.ws("echo", (ws, request) {
    print("WebSocket connected");

    ws.listen((message) {
        print("Received: $message");
    });
});
```

## Sending messages

`ws` is duplex, so you can use `add` and `addStream` to send messages. Below is an example of returning a received message to the client.

```dart
app.ws("echo", (ws, request) {
    print("WebSocket connected");

    ws.listen((message) {
        print("Received: $message");

        // Send the message back to the client
        ws.add(message);
    });
});
```

## Closing the connection

When you are finished communicating with the client, you must close the connection using the `close` method. **Otherwise the WebSocket connection will remain open**.

```dart
app.ws("echo", (ws, request) {
    print("WebSocket connected");

    ws.listen((message) {
        print("Received: $message");

        // Send the message back to the client
        ws.add(message);

        // Close the connection
        ws.close();
    });
});
```

## Learn more

- [WebSocket class](https://api.dart.dev/stable/dart-io/WebSocket-class.html)
- [WebSocket protocol](https://tools.ietf.org/html/rfc6455)

::: warning

1. In WebSocket routing, Exception Filter does not work because WebSocket routing does not throw exceptions. When your WebSocket route throws an exception, it automatically closes the connection.
2. You should avoid using middleware that operates `request.response`, because `response` is closed at this time, which will cause exceptions.
3. The `request` passed to closure is only used as Context, but you cannot read the body because the body is empty when WebSocket establishes the connection.

:::
