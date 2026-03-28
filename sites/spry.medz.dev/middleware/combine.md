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

## Next combine helpers

Spry is expected to grow this area with helpers such as:

- `except(...)`
- `some(...)`

Those need tighter semantic boundaries than `every(...)`, so they should be documented alongside this page as they land.
