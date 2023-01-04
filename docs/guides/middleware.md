---
title: Middleware
---

# Middleware

Spry middleware is a function that takes a `Context` object and a `MiddlewareNext` function, then performs some operations, and finally calls the `MiddlewareNext` function.

```dart
middleware(Context context, MiddlewareNext next) async {
   // do something
   await next();
}
```

## MiddlewareNext

`MiddlewareNext` is an asynchronous function that is equivalent to calling the next middleware or handler.

## Chain reaction middleware

In actual development, we may need to encapsulate a series of middleware. First, it is too cumbersome to register middleware through Spry's `use` method, and the spry object needs to be passed back and forth. To simplify this process, Spry provides a middleware extension, which can encapsulate a series of middleware into one middleware.

```dart
import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

final Middleware group = m1.use(m2).use(m3); // m1 -> m2 -> m3

spry.use(group);
```