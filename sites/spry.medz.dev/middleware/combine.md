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

## Next combine helper

Spry is still expected to grow this area with:

- `some(...)`

That helper needs tighter semantic boundaries than `every(...)` and `except(...)`, because the current Spry middleware contract does not include a generic “decline and continue trying” state.
