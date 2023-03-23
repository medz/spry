---
title: Application
---

# Application

[[toc]]

## What is an Spry?

Spry is a set of objects containing a series of middleware, and it is also an HttpServer processor. These middleware are combined and executed in a stack-like manner according to the request. Spry provides only a thin layer, at its core is the middleware, and the middleware is the heart of Spry.

## How to create a application?

To create a application, you need to import the `spry` package and create a `Spry` instance:

```dart
import 'package:spry/spry.dart';

final spry = Spry();
```

## How to use a application?

To use a application, you need to create a Spry Application and cell the Spry instance's `call` method:

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

## Built-in HTTP server

Spry provides a built-in HTTP server, which can be used to quickly create a HTTP server:

```dart
import 'package:spry/spry.dart';

final spry = Spry();

void handler(Context context) {
  context.response.text('Hello, world!');
}

void main() async {
  await spry.listen(handler, port: 8080);
}
```
