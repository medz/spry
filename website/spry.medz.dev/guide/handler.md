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

<<< ../../../example/middleware/01_logger.dart

This is the right place for:

- request logging
- tracing
- auth shells
- response timing

## Scoped middleware

Use `_middleware.dart` inside `routes/` when behavior should apply only to that branch of the route tree.

<<< ../snippets/quickstart/routes/_middleware.dart

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
