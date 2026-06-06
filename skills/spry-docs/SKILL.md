---
name: spry-docs
description: Authoritative guidance for working with Spry applications — project structure, filesystem routing, middleware, error handling, OpenAPI, client generation, build targets, and validation workflows. Use when building Spry apps, adding routes or middleware, configuring builds, or understanding Spry concepts.
license: MIT
compatibility: Designed for Claude Code, Codex, and compatible AI coding agents
metadata:
  version: "1.0"
  package: spry
---

# Spry Framework Guide

Spry is a Dart server framework centered on **filesystem routing** and **generated runtime output**. The filesystem is the source of truth for route structure — everything is explicit and inspectable.

## Project Structure

```text
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

Spry uses filesystem routing with expressive segments.

See [the routing reference](references/routing.md) for the full segment syntax and matching rules.

### HTTP Method Suffixes

Add `.get`, `.post`, `.put`, `.delete`, `.patch`, `.head`, `.options` before `.dart`:

- `routes/users.get.dart` → only `GET /users`
- `routes/users.post.dart` → only `POST /users`
- `routes/users.dart` → all methods

## Middleware

### Global Middleware

Files in `middleware/` apply to every request. See [middleware patterns](references/middleware.md).

### Scoped Middleware

Files named `_middleware.dart` inside `routes/` apply to that directory's scope. Can be method-specific: `routes/admin/_middleware.post.dart`.

## Handlers

Every route file exports handler functions matching HTTP methods. See [handler patterns](references/handlers.md).

## Configuration

`spry.config.dart` emits JSON config via `defineSpryConfig()`. See [config reference](references/config.md) for all options and build targets.

## Validation Commands

```bash
dart analyze          # static analysis
dart test             # run test suite
spry build            # build for configured target
spry serve            # dev server with watch mode
spry mcp              # start MCP server for AI tools
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

When the Spry MCP server is connected (`spry mcp`), prefer it over source-only inspection for route listing, config inspection, middleware chain analysis, and OpenAPI/client status. Fall back to source reading when MCP is not available.

## Build Targets

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
