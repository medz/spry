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

This is useful when a subset of routes needs shared locals, auth checks, or response wrapping.

## Error handling

Use `_error.dart` to catch errors inside the current route scope and convert them into a stable response shape.

<<< ../snippets/quickstart/routes/_error.dart

This is the clean path for:

- handling `NotFoundError`
- returning structured JSON errors
- avoiding repeated `try/catch` blocks in handlers

## Practical rule

- if it changes request flow across multiple routes, use middleware
- if it converts thrown errors into responses, use `_error.dart`
- if it belongs to one handler only, keep it inside that handler

For first-party middleware documentation and helper-specific behavior, use the dedicated [Middleware](/middleware/) section.

For websocket routes, middleware and `_error.dart` still apply during the handshake phase, but not after the upgrade is committed. Use that phase for auth, validation, and fallback decisions before calling `event.ws.upgrade(...)`. See [WebSockets](/guide/websocket).
