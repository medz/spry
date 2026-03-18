---
title: Cross-Platform Server
description: Spry generates a real server entrypoint that can run on multiple runtimes without rewriting your route layer.
---

# Cross-Platform Server

The point of Spry is not only to make route authoring pleasant. It is to keep the same Dart route tree portable across runtime targets.

## The runtime story

You write:

- `routes/` files
- optional global `middleware/`
- optional `public/` assets
- `hooks.dart`
- `spry.config.dart`

Spry generates:

- a concrete `Spry(...)` app
- a `main.dart` entrypoint for the selected target
- any target-specific wrapper files needed by that runtime

## Local serving

```bash
dart run spry serve
```

Spry reads `spry.config.dart`, scans the route tree, writes generated output, and runs the selected target using the configured reload strategy.

## Build output

```bash
dart run spry build
```

By default, the generated files are emitted into `.spry/`.

## How the pieces fit together

- `routes/` becomes the handler tree
- `middleware/` and `_middleware.dart` become middleware bindings
- `_error.dart` becomes scoped error boundaries
- `public/` becomes static asset lookup
- `spry.config.dart` decides which runtime entrypoint Spry emits

If you want field-by-field config details, read [Configuration](/config).

## Static assets and lifecycle hooks

`public/` is part of the request pipeline. On supported targets, Spry resolves `GET` and `HEAD` requests against `publicDir` before it falls through to the handler tree.

You can also define lifecycle hooks:

<<< ../../example/dart_vm/hooks.dart
