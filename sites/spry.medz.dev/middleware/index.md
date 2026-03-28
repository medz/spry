---
title: Middleware → Overview
description: Learn how Spry middleware works, when to use it, and how to create your own.
---

# Middleware Overview

Spry keeps request behavior explicit.

Middleware is the layer for cross-cutting request logic such as:

- request IDs
- logging
- response timing
- header shaping
- auth guards

If a concern changes request flow across multiple handlers, it belongs in middleware.

If it converts thrown errors into responses, it belongs in `_error.dart`.

## The contract

Spry middleware uses one small contract:

```dart
typedef Middleware = FutureOr<Response> Function(Event event, Next next);
```

That means a middleware can:

- continue by calling `next()`
- stop the pipeline by returning a `Response`

There is no extra hidden lifecycle around it.

## Global and scoped middleware

Spry supports two places for middleware:

### Global middleware

Files in top-level `middleware/` apply across the app and are loaded in filename order.

```text
middleware/
  01_request_id.dart
  02_logger.dart
```

### Scoped middleware

Use `_middleware.dart` inside `routes/` when behavior should apply only to one route branch.

```text
routes/
  admin/
    _middleware.dart
    users.get.dart
```

## Request-scoped state

Use `event.locals` when middleware needs to share data with downstream middleware or handlers.

```dart
Future<Response> middleware(Event event, Next next) async {
  event.locals.set(#startedAt, DateTime.now());
  return next();
}
```

This is the preferred place for request-scoped values such as request IDs, timing markers, and authenticated principals.

## First-party middleware

Spry exposes first-party middleware helpers from:

```dart
import 'package:spry/middleware.dart';
```

Current first-party middleware:

- [`every(...)`](/middleware/combine)
- [`requestId(...)`](/middleware/request-id)
- [`timing(...)`](/middleware/timing)

## Creating your own middleware

Custom middleware should stay small and explicit:

```dart
import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  final response = await next();
  response.headers.set('x-powered-by', 'spry');
  return response;
}
```

Use a first-party helper when the behavior is already covered.

Write your own middleware when the behavior is application-specific.
