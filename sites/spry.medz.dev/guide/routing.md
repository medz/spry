---
title: Guide → File Routing
description: Spry routes come from files and folders. Learn the naming rules that feed the generated app.
---

# File Routing

Spry v7 does not want you registering routes by hand. The filesystem is the source of truth.

## Start from `routes/`

The scanner walks every Dart file under `routes/` and turns it into a route, scoped middleware binding, or scoped error boundary.

```text
routes/
  index.dart
  about.get.dart
  users/[id].dart
  [...slug].dart
  _middleware.dart
  _error.dart
```

## Route files

### `index.dart`

`routes/index.dart` maps to `/`.

<<< ../snippets/quickstart/routes/index.dart

### Method-specific files

Append an HTTP method to restrict a file to that method:

<<< ../snippets/quickstart/routes/about.get.dart

That file maps to `GET /about`.

Supported suffixes are:

- `.get`
- `.post`
- `.put`
- `.patch`
- `.delete`
- `.head`
- `.options`

### Dynamic params

Square brackets create named params:

<<< ../snippets/quickstart/routes/users/[id].dart

`routes/users/[id].dart` maps to `/users/:id`.

### Catch-all files

Use `[...name].dart` for wildcard matches:

<<< ../snippets/quickstart/routes/[...slug].dart

The wildcard value is available through `event.params.wildcard`.

## Scoped files

### `_middleware.dart`

This file wraps all matching routes in the current directory scope:

<<< ../snippets/quickstart/routes/_middleware.dart

### `_error.dart`

This file catches errors thrown by matching routes in the current scope:

<<< ../snippets/quickstart/routes/_error.dart

## Global middleware

Files in top-level `middleware/` are collected separately and executed in filename order:

<<< ../../../example/middleware/01_logger.dart

## Scope rules that matter

- Files or folders that start with `_` are reserved for framework behavior.
- Catch-all directories cannot also define scoped middleware or scoped error files under the same wildcard shape.
- Spry rejects duplicate routes and param-name drift for the same route shape during scanning.
- The root fallback is the root-level catch-all route when present.
