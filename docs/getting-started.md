---
title: Getting Started
---

# Getting Started

Getting started with Spry.

## Installation

Install Spry run this command:

```bash
dart pub add spry
```

Or, update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: <latest | ^{version}>
```

## Quick Start

Creates a new file `app.dart`(or `main.dart` | `server.dart`):

```dart
import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry/ws.dart';
import 'package:spry/io.dart';

main() async {
    final app = createSpry();

    app.get('/', ((event) => 'Hello, Spry!');

    final handler = toIOHandler(app);
    final server = await HttpServer.bind('127.0.0.1', 3000);

    server.listen(handler);
    print('🎉 Server listen on http://127.0.0.1:3000');
}
```

Now run the development server using `dart run`:

```bash
dart run app.dart
```

And tadaa! We have a web server running locally.

## What happened?

Okay, let's now break down our example:

We first created an [Spry application][/guide/app] using `createSpry()`.
`app` is a tiny server capable of matching requests, generating response and handling lifecycle hooks (such as errors):

```dart
final app = createSpry();
```

Then we adds our first endpoint. in Spry, we define request handlers using a closure preceded by a `FutureOr<T> Function(Event)` type:

```dart
app.get('/', (event) => ...);
```

What is beautiful in Spry is that all you have to do to make a response, is to simply return it! Responses can be simple string, JSON objects, Uint8List or streams.

```dart
return '⚡️ Tadaa!';
```

We then use Spry’s built-in `dart:io` platform support to wrap the app instance into a handler that `HttpServer` can use:

```dart
final handler = toIOHandler(app);
```

Finally, we create an HTTP server from `dart:io` and listen for requests to pass to the Spry app:

```dart
final server = await HttpServer.bind('127.0.0.1', 3000);

server.listen(handler);
```
