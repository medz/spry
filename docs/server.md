---
title: Cross-Platform Server
description: Spry server provides a unified Server-API to create cross-platform servers. Including Dart, Bun, Node and Deno
---

# Cross-Platform Server

{{ $frontmatter.description }}

## Why Spry server?

When you want to create an HTTP server with Dart, you must use `dart:io`.

**Example**: `dart:io` HTTP server ([learn more](https://dart.dev/libraries/dart-io#http-server)):

```dart
void main() async {
  final requests = await HttpServer.bind('localhost', 8888);
  await for (final request in requests) {
    processRequest(request);
  }
}

void processRequest(HttpRequest request) {
  print('Got request for ${request.uri.path}');
  final response = request.response;
  if (request.uri.path == '/dart') {
    response
      ..headers.contentType = ContentType(
        'text',
        'plain',
      )
      ..write('Hello from the server');
  } else {
    response.statusCode = HttpStatus.notFound;
  }
  response.close();
}
```

But when you want to run on Node/Bun/Deno runtime, you can't use Dart language but only JS/TS (Node needs additional translation to use TS):

**Example**: Node.js HTTP server ([learn more](https://nodejs.org/en/learn/getting-started/introduction-to-nodejs)):
```typescript
import { createServer } from "node:http";

const server = createServer((req, res) => {
  res.end("Hello, Node.js!");
});

server.listen(3000, () => {
  console.log(`Server running at http://localhost:3000/`);
});
```

**Example**: Bun HTTP server ([learn more](https://docs.deno.com/api/deno/~/Deno.serve)):
```typescript
Bun.serve({ port: 3000, fetch: (req) => new Response("Hello, Bun!") });
```

**Example**: Deno HTTP server ([learn more](https://bun.sh/docs/api/http)):
```typescript
Deno.serve({ port: 3000 }, (_req, info) => new Response("Hello, Deno!"));
```

You should note that each runtime is different. In particular, you can't make your Dart code universal.

Therefore, Spry server hopes to serve as a cross-platform standard server layer, rather than relying on a single runtime API. Let your Dart code move forward in the Dart and JavaScript ecosystem with ease!

## Getting started

A server can be started using serve function from `package:spry/server.dart`.

<<< ../example/server.dart

## Fetch handler

Request handler is defined via fetch key since it is similar to [fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API).
The input is a `Request` object and handler should return a `Response` or a `Future` if the server handler is async.

**Example**:
```dart
import 'package:spry/server.dart';

void main() {
  serve(
    fetch: (request, _) {
      return Response.fromString('''
          <h1>👋 Hello there</h1>
          <p>You are visiting ${request.url} from ${request.address}</p>
        ''',
        headers: Headers({
          'Content-Type': 'text/html',
        }),
      );
    }
  );
}
```

## Server instance

When calling serve to start a server, a server instance will be immediately returned in order to control the server instance.

```dart
import 'package:spry/server.dart';

Future<void> main() async {
  final server = serve(fetch: (request, server) {
    return Response.fromString('🔥 Server is powered by ${server.runtime.runtimeType}');
  });
  await server.ready();

  print('🚀 Server is ready at ${server.url}');

  // When server is no longer needed
  // server.close();
}
```

### Server Properties

- `server.options`: Access to the sever options set during initialization.
- `server.url`: Get the computed server listening URL.
- `server.hostname`: Listening address (hostname or ipv4/ipv6).
- `server.port`: Listening port number.

### Server methods

- `server.ready()`: Returns a promise that will be resolved when server is listening to the port and ready to accept connections.
- `server.close([bool force = true])`: Stop listening to prevent new connections from being accepted.

## Server options

When starting a new server, in addition to main fetch handler, you can provide additional options to customize listening server.

```dart
serve(
  // Generic options
  port: 3000,
  hostname: "localhost",

  // Enabling this option allows multiple processes to bind to the same port, which is useful for load balancing.
  reusePort: true,

  // Main server handler
  fetch: (request, server) => new Response.formString("👋 Hello there!"),
);
```

## Deploy

To deploy your cross-platform HTTP server, please refer to the [Deploy guide](/deploy).

## API Reference

See the [API documentation](https://pub.dev/documentation/spry/latest/server/) for detailed information about all available APIs.
