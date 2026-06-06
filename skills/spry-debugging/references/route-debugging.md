# Advanced Route Debugging

## Route Resolution Process

When a request arrives, Spry resolves it through this pipeline:

1. **Public asset check** — if the path matches a file in `public/`, serve it directly
2. **Middleware chain** — run applicable scoped and global middleware
3. **Route matching** — find the best-matching route handler
4. **Fallback** — if no route matches, use the fallback handler
5. **Error chain** — if any step throws, run applicable error handlers

## Debugging Route Discovery Issues

### Verify the scanner found your route

Check the generated app file at `.spry/src/app.dart`. Look for your route path in the route map:

```dart
// Generated routes map
const routes = {
  '/users/[id]': {HttpMethod.get: users$get},
  // your route should appear here
};
```

### Common scanner issues

1. **File in wrong directory**: Routes must be in `routes/` (or the configured `routesDir`).
2. **Underscore prefix**: Files or directories starting with `_` are skipped by the scanner (except `_middleware.dart` and `_error.dart`).
3. **Non-Dart files**: Only `.dart` files are scanned.
4. **Invalid segment syntax**: Malformed `[...]` or `[[...]]` patterns cause the scanner to skip the file.

## Debugging Middleware Ordering

### Check the generated middleware chain

In `.spry/src/app.dart`, the middleware is wired in order:

```dart
final middleware = [
  // Scoped middleware first (specific → general)
  MiddlewareRoute(path: '/admin', handler: adminMiddleware),
  MiddlewareRoute(path: '/', handler: rootMiddleware),
  // Global middleware last
  MiddlewareRoute(path: '/**', handler: logger),
];
```

### Verify with MCP

```text
spry.explain_route(method: "GET", path: "/admin/users")
```

The `middleware_chain` field shows the exact execution order.

## Debugging Param Extraction

If route params are empty or wrong:

1. Check the route file's path pattern matches the request path
2. Verify param names match between the file name and `event.params` access
3. Regex constraints (`[id=\d+]`) only affect matching, not extraction — the param is still captured as a string

## Debugging 404 from Fallback

If the fallback handler returns 404:

1. Check the HTTP method — `routes/users.get.dart` won't match POST requests
2. Check for trailing slashes — `/users` vs `/users/`
3. Check case sensitivity — `caseSensitive: true` means `/Users` ≠ `/users`
4. Check for competing patterns — more specific routes take priority

## Debugging Build Output

When `spry build` produces unexpected output:

1. Inspect `.spry/src/app.dart` — the generated route wiring
2. Inspect `.spry/src/main.dart` — the runtime entry point
3. For JS targets, check the compiled `.js` or `.cjs` files in the output directory
