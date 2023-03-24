# WebSocket for Spry

Spry WebSocket is a Spry handler for handling WebSocket requests.

[![pub version](https://img.shields.io/pub/v/spry_websocket.svg)](https://pub.dartlang.org/packages/spry_websocket)

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  spry_websocket: latest
```

Or install it from the command line:

```bash
dart pub add spry_websocket
```

## Connected callback

The `onConnected` callback is called when a WebSocket connection is established.

```dart
void onConnected(Context context, WebSocketChannel channel) {
  channel.stream.listen((event) {
    channel.sink.add('Server received: $event');
  });
}
```

> **Note**: Although the Context is provided, you can get the Response from it, but you should not manipulate the response, especially in asynchronous situations, which may cause unexpected interruption of the program.

## Create a WebSocket handler

WebSocket handler is a Spry handler that handles WebSocket requests, but you need to use the `SpryWebSocket` class to create a WebSocket handler.

```dart
final handler = SpryWebSocket(onConnected: onConnected);
```

## Use WebSocket handler

```dart
final spry = Spry();

await spry.listen(websocket, pory: 3030);
```

If you not use the `Spry.listen` method, you can use the `Spry.call` method to handle the WebSocket request action:

```dart
final spry = Spry();
final websocket = SpryWebSocket(onConnection);
final server = await HttpServer.bind(InternetAddress.anyIPv4, 3030);

// Create a HTTP action
final action = spry(websocket);

// Handle the WebSocket request
await for (final request in server) {
  await action(request);
}
```

## Fallback

Spry WebSocket has a built-in default fallback for fallback calls on non-socket connections.

You can use this to tell the client that the server does not support WebSocket.

```dart
final handler = SpryWebSocket(
  onConnection,
  fallback: (context) {
    context.response.statusCode = HttpStatus.upgradeRequired;
    context.response.write('Upgrade Required');
  },
);
```

## Hybrid application

When you want to handle WebSocket events on a port that also supports HTTP requests, you can use the `fallback` parameter for HTTP request fallback.

```dart
final handler = SpryWebSocket(
  onConnection,
  fallback: (context) {
    context.response.statusCode = 200;
    context.response.text('Hello World');
  },
);
```

Now, when you access the WebSocket port through a browser, you will see the `Hello World` message.

```bash
curl http://localhost:3030
Hello World
```

### With [`spry_router`](https://pub.dartlang.org/packages/spry_router)

Spry WebSocket is a standard Spry handler, so it can be used with Spry Router.

For example, let your application support both HTTP requests and WebSocket requests:

```dart
final router = Router();
final websocket = SpryWebSocket(onConnection, fallback: router);

await spry.listen(websocket, port: 3030);
// ws://localhost:3030
// http://localhost:3030
```

You can also say that it is mounted under a certain path of the route:

```dart
final router = Router();
final websocket = SpryWebSocket(onConnection);

router.get('/echo', websocket); // ws://localhost:3030/echo
```

Or we want to make a different WebSocket program based on the path:

```dart
final router = Router();

final echo = SpryWebSocket(echoOnConnection);
final chat = SpryWebSocket(chatOnConnection);

router.get('/echo', echo); // ws://localhost:3030/echo
router.get('/chat', chat); // ws://localhost:3030/chat

await spry.listen(router, port: 3030);
```
