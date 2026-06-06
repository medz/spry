---
name: spry-debugging
description: Debugging playbooks for Spry applications — 404s, route mismatches, middleware ordering, error chains, OpenAPI generation, client generation, build/runtime errors. MCP-first when the Spry MCP server is connected. Use when debugging any Spry application issue.
license: MIT
compatibility: Requires a Spry project with spry.config.dart. MCP tools require spry mcp to be running.
metadata:
  version: "1.0"
  package: spry
---

# Spry Debugging Guide

Debugging playbooks for common Spry application issues. **When the Spry MCP server is connected, always prefer MCP tools over source-only inspection.**

## MCP-First Debugging

When `spry mcp` is connected, use these tools first:

| Problem | Start With |
|---|---|
| 404 / wrong route | `spry.explain_route` with method + path |
| Middleware not running | `spry.list_middleware` then `spry.explain_route` |
| Config not taking effect | `spry.get_config` |
| Route not discovered | `spry.list_routes` |
| OpenAPI issues | `spry.get_openapi_status` |
| Client gen issues | `spry.get_client_status` |
| General orientation | `spry.get_project_info` |

Only fall back to source reading when MCP tools don't provide enough detail.

## Playbook: 404 Not Found

### Step 1: Check route discovery
- **MCP**: `spry.list_routes` — is the expected route listed?
- **Manual**: Look in `.spry/src/app.dart` for the generated route map.

### Step 2: Check route matching
- **MCP**: `spry.explain_route(method: "GET", path: "/the/path")` — does it match?
- **Manual**: Compare route file pattern against request path.

### Step 3: Common causes
- **Wrong file name**: `routes/users.get.dart` matches `GET /users`, not `POST`.
- **Missing method export**: File must export a function matching the HTTP method.
- **Trailing slash**: `/users/` vs `/users` — check case sensitivity setting.
- **Param syntax**: `[id]` matches exactly one segment; `[...id]` matches zero or more.
- **Regex constraint too strict**: `[id=\\d+]` won't match alphabetic IDs.

### Step 4: Fallback check
If no route matches, the fallback (in `routes/index.dart`) handles the request. Verify a fallback is defined for catch-all behavior.

See [route debugging details](references/route-debugging.md) for advanced cases.

## Playbook: Middleware Not Running

1. **MCP**: `spry.list_middleware` — is the middleware listed?
2. **MCP**: `spry.explain_route` — check `middleware_chain` field.
3. **Check scope**: Scoped middleware in `routes/admin/_middleware.dart` applies to `/admin/*` only.
4. **Check ordering**: Middleware runs scoped-specific → scoped-general → global → handler. If a middleware returns without calling `next()`, later middleware won't run.
5. **Check method restriction**: `_middleware.post.dart` only applies to `POST`. Rename to `_middleware.dart` for all methods.

## Playbook: Error Handler Issues

1. **MCP**: `spry.list_error_handlers` — is the handler listed?
2. **Check chain**: Error handlers chain scoped-specific → scoped-general. If a handler re-throws, the next handler gets a chance.
3. **Unhandled errors**: `HTTPError` converts to Response automatically. Other errors propagate to the runtime.

## Playbook: OpenAPI Generation

1. **MCP**: `spry.get_openapi_status`
2. Verify `openapi` is configured in `spry.config.dart`
3. Check `.spry/public/openapi.json` (route output) or the configured local path
4. Run `spry build` to regenerate

## Playbook: Client Generation

1. **MCP**: `spry.get_client_status`
2. Run `spry build client` to regenerate
3. Output is in the configured `pkgDir` (default `.spry/client`)

## Playbook: Build / Runtime Errors

1. Run `spry build` and read the error output
2. **MCP**: `spry.get_config` — verify target, directories, settings
3. Inspect `.spry/` for generated files
4. For JS targets: ensure `dart compile js` succeeds
5. For Cloudflare: verify `wrangler.toml` exists or is configured

## Quick Reference

```bash
dart analyze          # static analysis
dart test             # run tests
spry build            # build for configured target
spry serve            # dev server with watch + hot reload
spry mcp              # start MCP server for AI tools
```
