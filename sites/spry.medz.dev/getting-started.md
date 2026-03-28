---
title: Getting Started
description: Build the smallest useful Spry project with file routing and a runtime config.
---

# Getting Started

Spry starts with a Dart project, a `routes/` directory, and a config file that tells the generated app where it should run.

## Install the package

```bash
dart pub add spry
```

## Create the runtime config

This is the control plane for local serve and production builds:

<<< ./snippets/quickstart/spry.config.dart

## Add your first route

Create `routes/index.dart`:

<<< ./snippets/quickstart/routes/index.dart

Spry treats this file as the handler for `/`.

## Start the dev server

```bash
dart run spry serve
```

By default, the generated app runs from your current project root and follows the values defined in `spry.config.dart`.

## Grow the route tree

You do not register routes imperatively. You add files:

```text [tree]
routes/
  index.dart
  about.get.dart
  users/[id].dart
  [...slug].dart
  _middleware.dart
  _error.dart
```

### `about.get.dart`

<<< ./snippets/quickstart/routes/about.get.dart

### `users/[id].dart`

<<< ./snippets/quickstart/routes/users/[id].dart

## Add middleware and scoped error handling

Middleware and error files are part of the same tree:

### `_middleware.dart`

<<< ./snippets/quickstart/routes/_middleware.dart

### `_error.dart`

<<< ./snippets/quickstart/routes/_error.dart

`_middleware.dart` applies to the current directory scope. You can also use
`_middleware.get.dart`, `_middleware.post.dart`, and the other supported method
suffixes to scope middleware to a single request method. `_error.dart` catches
errors raised by routes within the same scope.

## Build for production

When you are ready to generate the app entrypoint:

```bash
dart run spry build
```

Spry scans your project and writes the generated runtime output into `.spry/` by default.

## What to read next

- [Project Structure](/guide/app) shows how a real Spry project is organized.
- [File Routing](/guide/routing) explains naming, params, wildcard files, and scope rules.
- [OpenAPI](/guide/openapi) shows how to generate `openapi.json` from config and route metadata.
- [Middleware and Errors](/guide/handler) covers cross-cutting request behavior.
- [WebSockets](/guide/websocket) shows how to upgrade from a normal route handler.
- [Assets](/guide/assets) explains static files.
- [Lifecycle](/guide/lifecycle) covers hooks and request order.
- [Deploy Overview](/deploy/) covers Dart, Node, Bun, Cloudflare Workers, and Vercel.
