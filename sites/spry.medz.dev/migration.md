---
title: Migration Guide
description: Move from older imperative Spry APIs to the file-routing and generated-runtime workflow used by the v7 docs.
---

# Migration Guide

The v7 docs assume a different center of gravity than older Spry guides. The framework is now documented around file routing, generated output, and runtime targets selected in config.

## The headline shift

Old docs were centered on:

- `createSpry()`
- imperative route registration such as `app.get(...)`
- group-based route composition
- standalone server examples written by hand

The v7 docs are centered on:

- `routes/` as the source of truth
- `spry build` and `spry serve`
- `defineSpryConfig(...)`
- a generated `Spry(...)` app and target-specific runtime entrypoint

## What to replace

### Imperative route registration

If you previously wrote `app.get('/users/:id', handler);`, move that logic into `routes/users/[id].dart`.

### Route groups

If you relied on `app.group(...)`, stop modeling route structure in code. Use folders plus `_middleware.dart` for scope-level behavior.

### Manual server adapters

If your mental model was “I write the server wrapper myself”, move that concern into `spry.config.dart` and target selection.

### Request helpers

Prefer the request-scoped `Event` object:

- `event.request`
- `event.headers`
- `event.params`
- `event.locals`
- `event.context`

## The migration path that usually works

1. Move route logic into `routes/`.
2. Add `spry.config.dart`.
3. Replace shared wrappers with `middleware/` and scoped `_middleware.dart`.
4. Replace ad-hoc error translation with scoped `_error.dart`.
5. Run `dart run spry serve` and inspect the generated output.
