---
title: Guide → File Routing
description: Spry routes come from files and folders. Learn the naming rules that feed the generated app.
---

# File Routing

Spry does not want you registering routes by hand. The filesystem is the source of truth.

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

Each route file must expose a top-level `handler` binding assignable to
`Handler`. That can be a function declaration or a top-level variable.

### `index.dart`

`routes/index.dart` maps to `/`.

<<< ../snippets/quickstart/routes/index.dart

This is also valid:

```dart
import 'package:spry/spry.dart';

final handler = defineHandler(
  (event) => Response.json({'message': 'hello from spry'}),
);
```

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

Use `[...name].dart` for remainder matches:

<<< ../snippets/quickstart/routes/[...slug].dart

The remainder value is available through the declared param name, for example
`event.params.get('slug')`.

`routes/[...slug].dart` maps to `/**:slug`.

### Expressive segment syntax

Spry now forwards richer pathname syntax into `roux` through filesystem-safe file names:

| File or folder name | Route segment   |
| ------------------- | --------------- |
| `[id]`              | `:id`           |
| `[id([0-9]+)]`      | `:id([0-9]+)`   |
| `[[id]]`            | `:id?`          |
| `[...slug]`         | `**:slug`       |
| `[...]`             | `**`            |
| `[...path+]`        | `:path+`        |
| `[[...path]]`       | `:path*`        |
| `[_]`               | `*`             |
| `[name].[ext]`      | `:name.:ext`    |
| `post-[id].json`    | `post-:id.json` |

Notes:

- `[...name]` is a terminal remainder matcher. It can only appear at the end of a route.
- `[_]` is a single-segment wildcard. It matches exactly one path segment.
- `[[name]]`, `[...path+]`, and `[[...path]]` let one file cover optional or repeated suffix segments.
- Embedded params work anywhere inside a segment, so dots and literal prefixes stay intact.

## Scoped files

### `_middleware.dart`

This file wraps all matching routes in the current directory scope:

<<< ../snippets/quickstart/routes/_middleware.dart

You can also scope middleware to a single request method by adding the method
suffix before `.dart`:

- `routes/users/_middleware.get.dart`
- `routes/admin/_middleware.post.dart`

Supported method suffixes are:
`get`, `post`, `put`, `patch`, `delete`, `head`, and `options`.

### `_error.dart`

This file catches errors thrown by matching routes in the current scope:

<<< ../snippets/quickstart/routes/_error.dart

## Global middleware

Files in top-level `middleware/` are collected separately and executed in filename order:

<<< ../../../example/dart_vm/middleware/01_logger.dart

Global middleware uses the same suffix rule:

- `middleware/02_auth.get.dart`
- `middleware/03_audit.post.dart`

## Scope rules that matter

- Files or folders that start with `_` are reserved for framework behavior.
- Catch-all directories cannot also define scoped middleware or scoped error files under the same wildcard shape.
- Spry rejects duplicate routes and param-name drift for the same route shape during scanning.
- The root fallback is the root-level catch-all route when present.
