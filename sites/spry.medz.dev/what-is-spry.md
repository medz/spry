---
title: Why Spry
description: Why teams choose Spry for file routing, cross-runtime deployment, inspectable generated output, OpenAPI generation, and typed clients.
---

# Why Spry

Spry exists for teams that want a Dart server framework with a small authoring model, explicit build output, and the freedom to move across runtimes without rebuilding the application around a new platform abstraction.

It is built around one opinion:

> the filesystem should describe the server, and the framework should generate the runtime output needed to run it.

That gives Spry a different tradeoff profile from both low-level Dart server stacks and large batteries-included platforms.

## Why teams look at Spry

- `File routing without framework magic`
  Route files, `_middleware.dart`, and `_error.dart` define the shape of the app directly from the project tree.
- `Inspectable generated output`
  Spry emits concrete app and runtime entry files instead of hiding behavior inside a black box.
- `Cross-runtime deployment`
  The same project can target Dart VM, Node.js, Bun, Deno, Cloudflare Workers, Vercel, and Netlify.
- `OpenAPI and typed clients from the same source tree`
  Spry can generate API documentation and first-party typed clients from the real route model.
- `A small runtime model`
  Handlers return `Response` values directly, middleware composes explicitly, and runtime choice stays in config.

## What Spry is optimizing for

Spry is trying to be a sharp server layer, not a giant application container.

It is optimized for:

- APIs and backend services that benefit from file routing
- teams that want to start on Dart VM and keep deployment options open
- projects that want explicit build artifacts for review and debugging
- apps that benefit from generated OpenAPI documents and client SDKs

## The authoring model

You organize a Spry project like this:

```text
routes/
middleware/
public/
hooks.dart
spry.config.dart
```

Spry scans that structure and builds a concrete app definition from it. Route files define handlers. Scoped middleware and errors stay near the routes they affect. `spry.config.dart` decides how the generated output should run.

## What makes it different in practice

What you write:

- route handlers as normal Dart files
- optional route-local composition with `defineHandler(...)`
- scoped middleware and error boundaries in the filesystem
- runtime selection in config, not inside route code

What Spry generates:

- a concrete `Spry(...)` app definition
- runtime-specific entry files
- target-specific wrappers where platforms need them

## Good fit for

- teams evaluating Dart for backend work and wanting a cleaner authoring model
- API projects that need to ship across more than one runtime target
- codebases that want explicit output instead of hidden framework internals
- developers who want OpenAPI and typed client generation tied to real routes

## Less ideal for

- teams that want a full platform with ORM, auth, jobs, and admin already bundled
- applications that strongly prefer imperative route registration
- projects that only ever target one runtime and do not care about generated output or API contracts

## Runtime targets

Spry can emit output for:

- Dart VM
- Native executable and snapshots
- Node.js
- Bun
- Deno
- Cloudflare Workers
- Vercel
- Netlify Functions

## Start here

- [Getting Started](/getting-started) for the fastest path to a running project
- [File Routing](/guide/routing) to understand the authoring model
- [Client](/guide/client) and [OpenAPI](/guide/openapi) if you want stronger API contracts
- [Deploy Overview](/deploy/) if runtime flexibility is the main reason you are evaluating Spry
