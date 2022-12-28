---
title: Application
---

# Application

Spry is a set of objects containing a series of middleware, and it is also an HttpServer processor. These middleware are combined and executed in a stack-like manner according to the request. Spry provides only a thin layer, at its core is the middleware, and the middleware is the heart of Spry.

Mandatory Hello World

```dart
final Spry spray = Spry();

handler(Context context) {
   context.response.send('Hello World');
}

spry. listen(handler);
```

## Create a HttpServer handler

The core purpose of Spry is to return a request-handling function of HttpServer in `dart:io`. This function accepts an `HttpRequest` object from `dart:io` and closes the connection after processing the request.

## Middleware-style handlers

Spry can contain a series of middleware, use the `use` method to add middleware:

```dart
final Spry spray = Spry();

spry. use((Context context, MiddlewareNext next) async {
   // Do something
   await next();
});

spry. use((Context context, MiddlewareNext next) async {
   // Do something
   await next();
});

// Add more middleware
```