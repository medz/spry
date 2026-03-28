---
title: Middleware → Combine
description: Compose multiple Spry middleware with first-party combine helpers.
---

# Combine

Spry provides first-party helpers for composing middleware without changing the core middleware contract.

Import them from:

```dart
import 'package:spry/middleware.dart';
```

## `every(...)`

`every(...)` combines multiple middleware into one middleware and runs them in the provided order.

```dart
Middleware every(Iterable<Middleware> middlewares)
```

This:

```dart
every([a, b, c])
```

behaves like:

```dart
a(event, () => b(event, () => c(event, next)))
```

## Basic usage

```dart
import 'package:spry/middleware.dart';
import 'package:spry/spry.dart';

final middleware = every([
  requestId(),
  timing(),
]);
```

## Behavior

- Middleware runs in the provided order.
- `every([])` falls through to `next()`.
- If one middleware returns a `Response`, later middleware is not run.
- Errors continue through Spry's normal error pipeline.

## Why this exists

`every(...)` is useful when you want to bundle a few middleware into a reusable unit without introducing wrapper files whose only job is to forward to other middleware.

## `except(...)`

`except(...)` conditionally skips a middleware when its predicate matches.

```dart
Middleware except(
  Middleware middleware,
  bool Function(Event event) when,
)
```

When `when(event)` returns `true`, Spry skips the wrapped middleware and falls through to `next()`.

When `when(event)` returns `false`, Spry runs the wrapped middleware normally.

## Basic usage

```dart
import 'package:spry/middleware.dart';
import 'package:spry/spry.dart';

final middleware = except(
  timing(),
  (event) => event.pathname == '/healthz',
);
```

This is useful for excluding a specific middleware from health checks, internal probes, or other routes where the wrapped behavior should not apply.

## Behavior

- Matching requests skip the wrapped middleware and continue to `next()`.
- Non-matching requests run the wrapped middleware normally.
- Errors continue through Spry's normal error pipeline.

## `some(...)`

`some(...)` tries middleware in order and returns as soon as one candidate completes successfully.

```dart
Middleware some(
  Iterable<Middleware> middlewares, {
  SomeErrorThrower Function()? createThrower,
})
```

Unlike `every(...)`, `some(...)` is a fallback combiner:

- when a candidate returns normally, `some(...)` stops and returns that response
- when a candidate throws, `some(...)` silently tries the next candidate
- when every candidate throws, `some(...)` rethrows the selected tracked error

`some(...)` also wraps `next()` so all candidates share the same downstream result. If multiple candidates call `next()`, Spry still invokes the real downstream `next` only once.

## Basic usage

```dart
import 'package:spry/middleware.dart';

final jwtMiddleware = (event, next) async {
  throw Exception('JWT auth failed');
};

final sessionMiddleware = (event, next) async {
  return next();
};

final middleware = some([jwtMiddleware, sessionMiddleware]);
```

This shape is useful for fallback-style middleware, such as trying multiple authentication strategies in order until one succeeds.

## Behavior

- Middleware runs in the provided order.
- `some([])` throws during middleware construction.
- Returning normally counts as success, including returning the result of `next()`.
- Throwing counts as failure and moves on to the next candidate.
- By default, if every candidate fails, `some(...)` throws the first tracked error.

## `SomeErrorThrower`

`SomeErrorThrower` decides which tracked failure `some(...)` should throw after all candidates fail.

It is an open interface. Spry only ships two built-in strategies by default, but you can implement your own thrower when you need different failure selection behavior.

Spry includes two built-in factories:

- `SomeErrorThrower.first()`: throw the first tracked error
- `SomeErrorThrower.last()`: throw the last tracked error

This is why `some(...)` accepts:

```dart
SomeErrorThrower Function()? createThrower
```

The function is called per request, so custom throwers can keep request-local state without leaking across requests.

If you want `some(...)` to prefer the last failure instead of the default first failure:

```dart
final middleware = some(
  [jwtMiddleware, sessionMiddleware],
  createThrower: SomeErrorThrower.last,
);
```

You can also implement `SomeErrorThrower` yourself and pass it through `createThrower` when you want complete control over how failures are tracked and which error should finally be thrown. The built-in `first()` and `last()` factories are just the default strategies Spry provides out of the box.

## When to use it

Use `some(...)` only when throwing is an acceptable way for a candidate to signal failure.

This is a good fit for fallback middleware such as:

- multiple auth strategies
- alternate request resolvers
- optional guards with ordered fallback

It is usually a poor fit for middleware whose errors should always surface immediately, such as logging, timing, or other request diagnostics.
