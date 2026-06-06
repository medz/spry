---
name: spry-docs
description: Authoritative guidance for working with Spry applications — project structure, routing model, middleware, error handling, OpenAPI, client generation, build targets, and validation workflows.
metadata:
  type: reference
---

# Spry Framework Guide

Spry is a Dart server framework centered on **filesystem routing** and **generated runtime output**. The filesystem is the source of truth for route structure — everything is explicit and inspectable.

## Project Structure

```
my-app/
  routes/              # filesystem route handlers
    index.dart          # → GET /
    users/[id].dart     # → /users/:id
    _middleware.dart    # scoped middleware (optional)
    _error.dart         # scoped error handler (optional)
  middleware/           # global middleware
    logger.dart
  hooks.dart            # lifecycle hooks (onStart, onStop, onError)
  spry.config.dart      # build config (target, port, OpenAPI, client)
  public/               # static assets
  .spry/                # generated output (inspectable)
```

## Routing Model

Spry uses filesystem routing with expressive segments:

| File | Route |
|---|---|
| `routes/index.dart` | `/` |
| `routes/about.get.dart` | `GET /about` |
| `routes/users/[id].dart` | `/users/:id` |
| `routes/[...slug].dart` | `/:slug` (catch-all) |

### Expressive Segments

- `[param]` — named parameter
- `[param=regex]` — regex-constrained parameter
- `[[param]]` — optional parameter
- `[...param]` — repeated/wildcard parameter
- `[_...]` — ignored wildcard

### HTTP Method Suffixes

Add `.get`, `.post`, `.put`, `.delete`, `.patch`, `.head`, `.options` before `.dart` to restrict a route to a specific method:

- `routes/users.get.dart` → only matches `GET /users`
- `routes/users.post.dart` → only matches `POST /users`
- `routes/users.dart` → matches all methods

## Middleware

### Global Middleware

Files in `middleware/` apply to every request:

```dart
// middleware/logger.dart
Future<Response> logger(Event event, Next next) async {
  print('${event.request.method} ${event.request.url}');
  return next();
}
```

### Scoped Middleware

Files named `_middleware.dart` inside `routes/` apply to that directory's scope:

```dart
// routes/admin/_middleware.dart — applies to /admin/*
```

Can be method-specific: `routes/admin/_middleware.post.dart`.

Middleware runs from most-specific to least-specific scope, then globals, before the route handler.

## Error Handlers

### Scoped Error Handlers

Files named `_error.dart` inside `routes/` handle errors from that scope:

```dart
// routes/admin/_error.dart
Future<Response> errorHandler(Object error, StackTrace stack, Event event) async {
  if (error is HTTPError) return error.toResponse();
  return Response.json({'error': '$error'}, status: 500);
}
```

Error handlers chain: scoped first (most-specific → least-specific), then fall through if not handled.

## Handlers

Every route file exports handler functions matching HTTP methods:

```dart
// routes/users/[id].dart
import 'package:spry/spry.dart';

Future<Response> get(Event event) async {
  final id = event.params['id'];
  return Response.json({'id': id, 'name': 'User $id'});
}

Future<Response> post(Event event) async {
  final body = await event.request.json();
  return Response.json(body, status: 201);
}
```

### Event Context

The `Event` object provides:
- `event.request` — the incoming `Request`
- `event.params` — route parameters (`RouteParams`)
- `event.url` — parsed `Uri`
- `event.app` — the `Spry` application instance

### Fallback Handlers

`routes/index.dart` can export a `fallback` map for catch-all behavior:

```dart
final fallback = {
  null: (Event e) async => Response.notFound(),
};
```

## Configuration

`spry.config.dart` emits JSON config via `defineSpryConfig()`:

```dart
import 'package:spry/config.dart';

void main() => defineSpryConfig(
  target: BuildTarget.vm,
  port: 3000,
  openapi: OpenAPIConfig(...),
);
```

### Build Targets

| Target | Description |
|---|---|
| `vm` | Dart VM (dev/serve) |
| `exe` | Native executable |
| `aot` | AOT snapshot |
| `node` | Node.js |
| `bun` | Bun runtime |
| `deno` | Deno runtime |
| `cloudflare` | Cloudflare Workers |
| `vercel` | Vercel Functions |
| `netlify` | Netlify Functions |

## Validation Commands

```bash
dart analyze          # static analysis
dart test             # run test suite
spry build            # build for configured target
spry serve            # dev server with watch mode
spry build client     # generate client package
```

## Key Source Files

When inspecting Spry internals, start with:

| File | Purpose |
|---|---|
| `lib/src/app.dart` | Main `Spry` request pipeline |
| `lib/src/routing.dart` | Route/middleware/error router |
| `lib/src/event.dart` | Request-scoped `Event` context |
| `lib/src/errors.dart` | `HTTPError` and error conversion |
| `lib/src/builder/scanner.dart` | Filesystem route scanning |
| `lib/src/builder/generator.dart` | Generated code emission |
| `lib/src/builder/config.dart` | Build config loading |

## MCP Inspection

When the Spry MCP server is connected (`spry mcp`), prefer it over source-only inspection for:
- Route listing and explanation
- Middleware/error chain composition
- Config inspection
- OpenAPI and client generation status

Fall back to source reading when the MCP server is not available or for implementation details it doesn't expose.
