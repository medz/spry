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

## Which one should you use?

Use the helper that matches the way you want requests to flow:

- `every(...)`: run several middleware as one ordered middleware chain
- `except(...)`: skip one middleware when a request matches a condition
- `some(...)`: try several candidate middleware in order until one succeeds

## `every(...)`

Use `every(...)` when you want to bundle several middleware into one reusable chain.

```dart
Middleware every(Iterable<Middleware> middlewares)
```

`every([a, b, c])` behaves like:

```dart
a(event, () => b(event, () => c(event, next)))
```

### Basic usage

```dart
import 'package:spry/middleware.dart';
import 'package:spry/spry.dart';

final middleware = every([
  requestId(),
  timing(),
]);
```

### Behavior

- Middleware runs in the provided order.
- `every([])` falls through to `next()`.
- If one middleware returns a `Response`, later middleware is not run.
- Errors continue through Spry's normal error pipeline.

### Why this exists

`every(...)` is useful when you want one route binding to apply a small stack of middleware without creating a wrapper file whose only job is to forward to other middleware.

## `except(...)`

Use `except(...)` when one middleware should apply almost everywhere, but not on a small set of routes.

```dart
Middleware except(
  Middleware middleware,
  bool Function(Event event) when,
)
```

When `when(event)` returns `true`, Spry skips the wrapped middleware and continues to `next()`. Otherwise, Spry runs the wrapped middleware normally.

### Basic usage

```dart
import 'package:spry/middleware.dart';
import 'package:spry/spry.dart';

final middleware = except(
  timing(),
  (event) => event.pathname == '/healthz',
);
```

This is useful for excluding middleware from health checks, internal probes, or other routes where the wrapped behavior should not apply.

### Behavior

- Matching requests skip the wrapped middleware and continue to `next()`.
- Non-matching requests run the wrapped middleware normally.
- Errors continue through Spry's normal error pipeline.

## `some(...)`

Use `some(...)` when you have several fallback candidates and any one of them succeeding is enough.

```dart
Middleware some(
  Iterable<Middleware> middlewares, {
  SomeErrorThrower Function()? createThrower,
})
```

`some(...)` is different from `every(...)`: it is not trying to run everything. It is trying candidates one by one until one completes successfully.

### Basic usage

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

This is useful for fallback-style middleware such as trying multiple authentication strategies in order until one works.

### Behavior

- Middleware runs in the provided order.
- `some([])` throws during middleware construction.
- Returning normally counts as success, including returning the result of `next()`.
- Throwing counts as failure and moves on to the next candidate.
- By default, if every candidate fails, `some(...)` throws the first tracked error.
- All candidates share the same wrapped `next()`, so downstream `next` is still only executed once.

### `SomeErrorThrower`

Most users do not need to think about `SomeErrorThrower`. It only matters when every `some(...)` candidate fails.

`SomeErrorThrower` decides which tracked failure `some(...)` should finally throw:

- `SomeErrorThrower.first()`: throw the first tracked error
- `SomeErrorThrower.last()`: throw the last tracked error

If you want `some(...)` to prefer the last failure instead of the default first failure, pass a custom strategy:

```dart
final middleware = some(
  [jwtMiddleware, sessionMiddleware],
  createThrower: SomeErrorThrower.last,
);
```

`SomeErrorThrower` is an open interface. Spry ships `first()` and `last()` as built-in defaults, but you can implement your own thrower if you need custom failure selection behavior.

### When to use it

Use `some(...)` only when throwing is an acceptable way for a candidate to signal failure.

This is a good fit for fallback middleware such as:

- multiple auth strategies
- alternate request resolvers
- optional guards with ordered fallback

It is usually a poor fit for middleware whose errors should always surface immediately, such as logging, timing, or other request diagnostics.
