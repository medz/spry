---
title: Middleware
---

# Middleware

[[toc]]

## What is middleware?

Middleware is a function that takes a [`Context`](/docs/fundamentals/context) and a [`Next`](#what-is-a-next-function) function and returns a `void` or a `Future<void>`.

## What is a next function?

This next function is to call the next middleware in the chain or the handler if it is the last middleware in the chain.

If you don't call the next function, the request will be stuck in the middleware.

## Function-based middleware

The simplest middleware is a function that returns `void`:

```dart
void middleware(Context context, Next next) {
  // Do something
  return next();
}
```

The middleware can also return a `Future<void>`:

```dart
Future<void> middleware(Context context, Next next) async {
  // Do something
  await next();
}
```

## Class-based middleware

Dart allows you to create a class with a `call` method, which can be used as a middleware:

```dart
class Middleware {
  void call(Context context, Next next) {
    // Do something
    return next();
  }
}
```

## Before middleware

Before middleware is a middleware that runs before the handler.

```dart
void beforeMiddleware(Context context, Next next) {
  // Do something

  return next();
}
```

## After middleware

After middleware is a middleware that runs after the handler.

```dart
Future<void> afterMiddleware(Context context, Next next) async {
 await next();

 // Do something
}
```

## Example

We can use the middleware to log the request and response:

```dart
Future<void> loggerMiddleware(Context context, Next next) async {
  final request = context.request;
  print('Request: ${request.method} ${request.uri}');

  await next();

  final response = context.response;
  print('Response: ${response.statusCode}');
}
```

## How to use middleware?

To use middleware, you need to create a [Spry Application](/docs/fundamentals/application) and call the Spry instance's `use` method:

```dart
import 'package:spry/spry.dart';

final spry = Spry();

spry.use(loggerMiddleware);
```
