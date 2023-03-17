---
title: Context
---

# Context

A Spry context encapsulates node request and response objects into a single object that provides many useful methods for writing web applications and APIs.

Context is created on request and passed between middleware and handlers. As shown in the example below:

```dart
final Spry spry = Spry();

spry.use((Context context, Next next) async {
   final Request request = context.request;
   final Response response = context.response;

   await next();
});
```

## context.request

`context.request` is a `Request` object, which contains request information, such as request method, request path, request header information, request content, etc.

## context.response

`context.response` is a `Response` object, which contains response information, such as response status code, response header information, response content, etc.

## Get a value from context

`context[key]` can get the value set by middleware or handler. Usually these values are set in middleware and then retrieved in handlers.
Of course, you can also set the value in the handler and get it in the middleware.

```dart
spry.use((Context context, Next next) async {
   context['foo'] = 'bar';

   await next();

   print(context. get('bar'));
});
```

> **Note:** If the value is not set, the value returned by `context[key]` is `null`.

## Store a value in context

`context[key] = value` can set the value set by the middleware or handler. Usually these values are set in middleware and then retrieved in handlers.

```dart
spry.use((Context context, Next next) async {
   context['foo'] = 'bar';

   await next();
});
```

## context.contains

`context.contains` is used to determine whether the value set by the middleware or handler exists.

## Read Spry instance from context

If you need to get the Spry instance from the context, you can use `context.app`.

```dart
import 'package:spry/extensions.dart';

final spry = context.app;
```

> Read the `context.app` property you need to import the `package://spry/extensions.dart` package.
