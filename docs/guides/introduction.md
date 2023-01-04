---
title: Waht is Spry?
---

# What is Spry?

Spry is an HTTP middleware framework for Dart to make web applications and APIs more enjoyable to write.

[![pub package](https://img.shields.io/pub/v/spry.svg)](https://pub.dartlang.org/packages/spry)

## Philosophy

Spry is a framework for building web applications and APIs. It is designed to be minimal and flexible.

## Motivation

We like Shelf, but we think it has some issues:

- Http Server is built-in, we want to be able to choose Http Server ourselves
- The path rules of routing are not flexible enough, and are not the familiar path rules
- The support for mount is not good enough, we want to be able to mount a sub-application or prefix in a handler and also apply to path rules.
- The design of the middleware is not flexible enough, and it contains an extra layer of useless functions, which is not elegant enough. At the same time rely on the return value of the handler or manually create a new response.
- For Response, the shelf needs to manually copy and create new responses continuously, which is not an elegant design.

We desperately wanted a better, more flexible framework, so we created spry.The design of Spry is inspired by many frameworks in the NodeJS ecosystem, such as Express, Koa, Hapi, etc.

## Pure Http Server listening handler

Spry is a pure Http Server listening processor. After we create Spry, it is a processor that directly receives HttpRequest. We can use it freely:

```dart
import 'package:spry/spry.dart';

void main() async {
   final Spry spry = Spry();

   /// Create a HttpServer listen handler
   final handler = spry((Context context) {
     // Do something
   });

   /// Create a HttpServer
   final server = await HttpServer.bind('localhost', 8080);

   /// Listen to the HttpServer
   server.listen(handler);
}
```

Of course, we can also use Spry's built-in HttpServer:

```dart
import 'package:spry/spry.dart';

void main() async {
   final Spry spry = Spry();

   //Create a Spry handler
   handler(Context context) {
     // Do something
   }

   // Listen to the HttpServer
   await spry.listen(handler);
}
```

## Middleware-style handlers

Spry is a middleware-style processor, we can use middleware to process requests:

```dart
final Spry spry = Spry();

spry.use((Context context, MiddlewareNext next) async {
   // Do something
   await next();
});

handler(Context context) {
   // Do something
}

spry.listen(handler);
```

## Read-only requests

Spry's request is read-only. We can get the requested information through `Context`, but we cannot modify the requested information. This design allows us to focus more on processing the request instead of modifying it.

```dart
final Spry spry = Spry();

spry.use((Context context, MiddlewareNext next) async {
   // Get the request
   final request = context. request;

   // Do something

   await next();
});
```

## writable response

Spry's response is writable, and we can modify the response information through `Context`, such as setting the status code of the response, the header information of the response, the content of the response, and so on.

```dart
final Spry spry = Spry();

spry.use((Context context, MiddlewareNext next) async {
   // Get the response
   final response = context. response;

   // Do something

   await next();
});
```