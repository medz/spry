---
name: spry-debugging
description: Debugging playbooks for Spry applications — 404s, route mismatches, middleware issues, OpenAPI generation, client generation, runtime/target errors. MCP-first when the Spry MCP server is connected.
metadata:
  type: reference
---

# Spry Debugging Guide

This skill provides repeatable debugging playbooks for common Spry application issues. **When the Spry MCP server is connected, always prefer MCP tools over source-only inspection.**

## MCP-First Debugging

When `spry mcp` is connected to your AI agent, use these tools first:

| Problem | Start With |
|---|---|
| 404 / wrong route | `spry.explain_route` with the failing method + path |
| Middleware not running | `spry.list_middleware` then `spry.explain_route` |
| Config not taking effect | `spry.get_config` |
| Route not discovered | `spry.list_routes` |
| OpenAPI issues | `spry.get_openapi_status` |
| Client gen issues | `spry.get_client_status` |
| General orientation | `spry.get_project_info` |

Only fall back to source reading when MCP tools don't provide enough detail (e.g. inspecting handler implementation logic).

## Playbook: 404 Not Found

### 1. Check route discovery
- **MCP**: `spry.list_routes` — is the expected route listed?
- **Manual**: Look in `.spry/src/app.dart` for the generated route map.

### 2. Check route matching
- **MCP**: `spry.explain_route(method: "GET", path: "/the/path")` — does it match?
- **Manual**: Compare the route file pattern against the request path.

### 3. Common causes
- **Wrong file name**: `routes/users.get.dart` matches `GET /users`, not `POST`.
- **Missing method export**: Does the file export a function matching the HTTP method?
- **Trailing slash**: `/users/` vs `/users` — check case sensitivity and trailing slash behavior.
- **Param syntax**: `[id]` matches exactly one segment; `[...id]` matches zero or more.
- **Regex constraint too strict**: `[id=\d+]` won't match alphabetic IDs.

### 4. Fallback check
If no route matches, the fallback (in `routes/index.dart`) handles the request. Verify a fallback is defined if you expect catch-all behavior.

## Playbook: Middleware Not Running

### 1. Check middleware discovery
- **MCP**: `spry.list_middleware` — is the middleware listed?
- **Manual**: Verify the file is in `middleware/` (global) or named `_middleware.dart` (scoped).

### 2. Check scope
- **MCP**: `spry.explain_route` for the request path — check the `middleware_chain` field.
- **Manual**: Scoped middleware in `routes/admin/_middleware.dart` applies to `/admin/*` only.

### 3. Check ordering
Middleware runs: scoped (most-specific → least-specific) → global → route handler. A middleware calling `next()` passes control to the next layer. If a middleware returns a Response without calling `next()`, later middleware won't run.

### 4. Check method restriction
A file named `routes/_middleware.post.dart` only applies to `POST` requests. Rename to `_middleware.dart` to apply to all methods.

## Playbook: Error Handler Issues

### 1. Check error handler discovery
- **MCP**: `spry.list_error_handlers` — is the handler listed?
- **Manual**: Verify the file is named `_error.dart` in the correct scope directory.

### 2. Check the error chain
Error handlers chain the same way as middleware: scoped-specific → scoped-general. If an error handler re-throws after processing, the next handler in the chain gets a chance.

### 3. Unhandled errors
If no error handler catches the error, Spry converts `HTTPError` to a Response automatically. Other errors propagate to the runtime.

## Playbook: OpenAPI Generation

### 1. Check config
- **MCP**: `spry.get_openapi_status`
- **Manual**: Verify `openapi` is configured in `spry.config.dart`.

### 2. Verify output
- Check `.spry/public/openapi.json` (route output) or the configured local path.
- Run `spry build` to regenerate.

### 3. Missing routes in schema
Routes export OpenAPI metadata via the `openapi` variable. Verify route files export it.

## Playbook: Client Generation

### 1. Check config
- **MCP**: `spry.get_client_status`
- **Manual**: Verify `client` is configured in `spry.config.dart`.

### 2. Regenerate
```bash
spry build client
```

### 3. Verify output
Client code is generated in the configured `pkgDir` (default `.spry/client`).

## Playbook: Build / Runtime Errors

### 1. Check target setup
```bash
spry build
```
Read the error output carefully — it usually identifies the failing target or compilation step.

### 2. Config validation
- **MCP**: `spry.get_config` — verify target, directories, and other settings.

### 3. Generated output inspection
Check `.spry/` for the generated Dart/JS files. The generated code is explicit and inspectable.

### 4. Dart VM (dev)
```bash
dart run spry serve
```
The dev server watches for file changes and rebuilds automatically.

### 5. JS targets (Node, Bun, Cloudflare, Vercel, Netlify)
Ensure `dart compile js` succeeds. For Cloudflare, verify `wrangler.toml` exists or is configured in `spry.config.dart`.

## Quick Reference

```bash
dart analyze          # static analysis
dart test             # run tests
spry build            # build for configured target
spry serve            # dev server with watch + hot reload
spry mcp              # start MCP server for AI tools
```

## When MCP Is Not Available

1. Read `.spry/src/app.dart` — the generated route/middleware/error wiring
2. Read `spry.config.dart` — the project configuration
3. Read the relevant route/middleware/error source file
4. Use `dart analyze` to catch syntax/type issues
5. Run `spry build` and inspect any build errors
