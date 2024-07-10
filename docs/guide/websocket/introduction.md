---
title: WebSocket → Introduction
---

# Introduction

Writing a real-time WebSocket server that works across different WebSocket runtimes is challenging because there is no single standard for WebSocket servers. You usually need to learn a lot of details about different API implementations, which also makes switching from one runtime to another expensive. Spry WebSocket is the solution to this problem!

## Basic using...

```dart
import 'package:spry/websocket.dart';

app.ws('/chat/rooms/:id', chatRoomHooks);
```

## Platform runtime

`package:spry/websocket.dart` exports a mixin for `WebSocketPlatform<T, R>` that only works on `Platform<T, R>`.

If the platform implementation you are using does not implement 'WebSocketPlatform', then your app will not support WebSockets.

## `app.ws`

This is a method for extending the Spry app instance to register WebSocket [Hooks](/guide/websocket/hooks):

```dart
class ChatHooks implements Hooks {
    ...
}

app.ws('chat', ChatHooks());
```
