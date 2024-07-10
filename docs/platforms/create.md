---
title: Platforms → Create a new platform
---

# Platform

Run Spry everywhere using platforms.

---

The app instance of Spry is lightweight without any logic about runtime it is going to run. Using Spry `Platform`, we can easily integrate server with each runtime.

There are 2 base platforms:

* [**Plain**](/platforms/plain)
* [**IO(`dart:io`)**](/platfrms/io)

## Create a new platform

To create a new platform support, we only need to implement the `Platform` interface:

```dart
typedef Input = <Your request type>;
typedef Output = <Your returns value type>;

class MyPlatform extends Platform<Input, Output> {
    ...
}
```

## WebSocket support

In general, WebSocket support is optional. If your platform supports WebSocket, you only need to `with WebSocketPlatform<T, R>` on your platform implementation:

```dart
class MyPlatform
    extends Platform<Input, Output>
    with WebSocketPlatform<Input, Output>
{
    FutureOr websocket(Event event, Input request, Hooks hooks) {
        // Your platform upgrading websocket logic.
    }
}
```
