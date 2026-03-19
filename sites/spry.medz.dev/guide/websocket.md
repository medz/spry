---
title: Guide → WebSockets
description: Accept websocket upgrades from normal route handlers without introducing a second routing system.
---

# WebSockets

Spry handles websockets through the normal request lifecycle. You do not create a second router or a websocket-only file suffix.

Use a normal route file and upgrade the request from `event.ws`.

## The shape

Create a normal route such as `routes/chat.get.dart`:

```dart
import 'package:spry/spry.dart';
import 'package:spry/websocket.dart';

Response handler(Event event) {
  if (!event.ws.isSupported || !event.ws.isUpgradeRequest) {
    return Response('plain http fallback');
  }

  return event.ws.upgrade((ws) async {
    ws.sendText('connected');

    await for (final message in ws.events) {
      switch (message) {
        case TextDataReceived(text: final text):
          ws.sendText('echo:$text');
        case BinaryDataReceived():
        case CloseReceived():
          break;
      }
    }
  }, protocol: 'chat');
}
```

This keeps the authoring model consistent:

- the filesystem still chooses the route
- the handler still returns a `Response`
- websocket acceptance stays explicit in route code

## `event.ws`

Spry groups websocket behavior under the request event:

- `event.ws.isSupported`
- `event.ws.isUpgradeRequest`
- `event.ws.requestedProtocols`
- `event.ws.upgrade(handler, {String? protocol})`

Import `package:spry/websocket.dart` when you need websocket types such as `WebSocket`, `TextDataReceived`, or `CloseReceived`.

## Fallbacks

Spry does not force every route to become websocket-only. You can branch explicitly and return a normal HTTP response when the request is not a websocket upgrade:

```dart
Response handler(Event event) {
  if (!event.ws.isSupported || !event.ws.isUpgradeRequest) {
    return Response.json({'mode': 'http'});
  }

  return event.ws.upgrade((ws) async {
    await ws.events.drain<void>();
  });
}
```

If you call `event.ws.upgrade(...)` without checking first:

- Spry throws `501` when the active runtime does not support websocket upgrades
- Spry throws `426` when the current request is not a websocket upgrade attempt

## Middleware and errors

Websocket upgrades still enter through the normal request pipeline.

That means:

- global middleware still runs
- scoped `_middleware.dart` still runs
- handshake-time errors can still be translated by scoped `_error.dart`

After the runtime commits the websocket upgrade, the session is no longer part of the normal HTTP response flow.

That means:

- websocket message events do not re-enter middleware
- websocket session errors do not flow through `_error.dart`
- uncaught session errors follow the underlying runtime websocket behavior

## Route conventions

Keep websocket routes as normal HTTP route files:

- `routes/chat.get.dart`
- `routes/rooms/[id].get.dart`

This matches the protocol model. A websocket handshake is still an HTTP request, and in practice it should stay on `GET` routes.

Spry does not currently define:

- `*.ws.dart` route files
- websocket-specific middleware files
- websocket-specific error route files

## Runtime support

Current websocket support follows the shared `osrv` runtime surface:

- supported: Dart VM, Node.js, Bun, Deno, Cloudflare Workers
- unsupported: Vercel, current Netlify Functions runtime

When a runtime family is unsupported, `event.ws.isSupported` is `false`.

## Practical rule

Use websockets when you really need a long-lived session. Keep everything else as ordinary route handlers. Spry is easiest to reason about when realtime behavior stays explicit at the route level instead of becoming a parallel framework model.
