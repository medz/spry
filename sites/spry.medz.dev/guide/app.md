---
title: Guide → Project Structure
description: Organize a Spry project around a small set of folders and let the framework do the repetitive work.
---

# Project Structure

Spry is easiest to understand when you start from the project tree, not from framework internals.

## Default layout

```text
.
├─ routes/
│  ├─ index.dart
│  ├─ users/[id].dart
│  ├─ _middleware.dart
│  └─ _error.dart
├─ middleware/
│  └─ 01_logger.dart
├─ public/
│  └─ hello.txt
├─ hooks.dart
└─ spry.config.dart
```

Each part has a narrow job:

- `routes/` defines route handlers
- `middleware/` defines global middleware
- `public/` holds static assets served directly
- `hooks.dart` defines lifecycle hooks
- `spry.config.dart` configures target, output, and local runtime behavior

## What belongs where

### `routes/`

Put request handlers here. This is the center of the app.

<<< ../snippets/quickstart/routes/index.dart

### `middleware/`

Put global request behavior here when it should apply broadly across the app.

<<< ../../../example/middleware/01_logger.dart

### `public/`

Put static files here when they should be served without going through a route handler.

```text
public/
  robots.txt
  logo.svg
  hello.txt
```

### `hooks.dart`

Put startup and shutdown behavior here:

<<< ../../../example/hooks.dart

### `spry.config.dart`

Put runtime choice and build behavior here:

<<< ../snippets/quickstart/spry.config.dart

## Why this structure works

Spry is opinionated about where files live so that the happy path stays obvious:

- route files are easy to scan
- cross-cutting behavior has a small number of entrypoints
- runtime choice is separated from route logic

That is the real authoring model. You should not need to think about generated internals during normal development.
