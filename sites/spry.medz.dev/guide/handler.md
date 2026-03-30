---
title: Guide → Middleware and Errors
description: Use middleware for cross-cutting request behavior and scoped error handlers for response shaping.
---

# Middleware and Errors

Spry keeps request behavior in two explicit places:

- middleware for cross-cutting flow control
- error handlers for translating failures into responses

## Global middleware

Files in top-level `middleware/` are loaded in filename order.

<<< ../../../example/dart_vm/middleware/01_logger.dart

If a middleware should apply only to one HTTP method, add the method suffix
before `.dart`, for example:

- `middleware/02_auth.get.dart`
- `middleware/03_audit.post.dart`

This is the right place for:

- request logging
- tracing
- auth shells
- response timing

For first-party middleware helpers such as `requestId(...)`, see [Middleware Overview](/middleware/).

## Scoped middleware

Use `_middleware.dart` inside `routes/` when behavior should apply only to that branch of the route tree.

<<< ../snippets/quickstart/routes/_middleware.dart

Scoped middleware supports the same method suffix convention:

- `routes/admin/_middleware.get.dart`
- `routes/admin/_middleware.delete.dart`
- `routes/admin/_error.get.dart`
- `routes/admin/_error.delete.dart`

This is useful when a subset of routes needs shared locals, auth checks, or response wrapping.

## Error handling

Use `_error.dart` to catch errors inside the current route scope and convert them into a stable response shape.

<<< ../snippets/quickstart/routes/_error.dart

Scoped error handlers support the same method suffix convention as scoped
middleware, for example `_error.get.dart` and `_error.delete.dart`.

This is the clean path for:

- handling `NotFoundError`
- returning structured JSON errors
- avoiding repeated `try/catch` blocks in handlers

## One handler only

If middleware or error shaping belongs to one handler only, use
`defineHandler(...)` instead of creating `_middleware.dart` or `_error.dart`
files for that one-off case.

```dart
import 'package:spry/spry.dart';

final handler = defineHandler(
  (event) async {
    return Response.json({'ok': true});
  },
  middleware: [
    (event, next) async {
      if (event.headers.get('x-demo') == null) {
        throw const HTTPError(400, body: 'missing x-demo');
      }
      return next();
    },
  ],
  onError: (error, stackTrace, event) {
    if (error case HTTPError()) {
      return error.toResponse();
    }

    rethrow;
  },
);
```

`defineHandler(...)` keeps the normal Spry ordering:

- global and scoped filesystem middleware still run outside the handler
- local middleware wraps only that handler
- local `onError` only catches that local chain
- rethrowing still bubbles into scoped `_error.dart`

## Practical rule

- if it changes request flow across multiple routes, use middleware
- if it converts thrown errors into responses, use `_error.dart`
- if it belongs to one handler only, use `defineHandler(...)` or keep it inline

For first-party middleware documentation and helper-specific behavior, use the dedicated [Middleware](/middleware/) section.

For websocket routes, middleware and `_error.dart` still apply during the handshake phase, but not after the upgrade is committed. Use that phase for auth, validation, and fallback decisions before calling `event.ws.upgrade(...)`. See [WebSockets](/guide/websocket).
