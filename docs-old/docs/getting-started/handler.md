---
title: Handler
---

# Handler

[[toc]]

## What is a handler?

Spry handler is a function that takes a [`Context`](/docs/fundamentals/context) and returns a `void` or a `Future<void>`.

The handler is responsible for processing the request and sending the response.

## Void Function-based handler

The simplest handler is a function that returns `void`:

```dart
void handler(Context context) {
  context.response.text('Hello, world!');
}
```

## Future Function-based handler

The handler can also return a `Future<void>`:

```dart
Future<void> handler(Context context) async {
  context.response.text('Hello, world!');
}
```

## Class-based handler

Dart allows you to create a class with a `call` method, which can be used as a handler:

```dart
class Handler {
  void call(Context context) {
    context.response.text('Hello, world!');
  }
}
```

## How to use a handler?

To use a handler, you need to create a [Spry Application](/docs/fundamentals/application) and cell the Spry instance's `call` method:

```dart
import 'package:spry/spry.dart';

final spry = Spry();

void main() async {
  final action = spry(handler);

  final server = await HttpServer.bind('localhost', 8080);
  await for (final request in server) {
    action(request);
  }
}
```

If you not familiar with the `HttpServer` class, you can use the `Spry.listen` method:

```dart
import 'package:spry/spry.dart';

final spry = Spry();

void main() async {
  spry.listen(handler, port: 8080);
}
```
