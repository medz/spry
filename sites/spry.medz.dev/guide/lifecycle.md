---
title: Guide → Lifecycle
description: Understand the order in which Spry handles a request and where hooks fit into the app.
---

# Lifecycle

Spry is easier to reason about when you know the request order.

## Request flow

For an incoming request, Spry works through these layers:

1. check `public/` for matching `GET` or `HEAD` assets
2. match the route handler from `routes/`
3. create the request-scoped `Event`
4. run global and scoped middleware
5. run the matched handler or fallback
6. if something throws, run scoped `_error.dart` handlers

This is the part people actually care about during development: where behavior can intercept a request.

## Lifecycle hooks

Use `hooks.dart` for process-level lifecycle work:

<<< ../../../example/dart_vm/hooks.dart

This is a good place for:

- startup logging
- runtime warm-up
- teardown work

## Mental model

Middleware shapes request flow. Hooks shape process lifecycle. Route handlers shape the response.
