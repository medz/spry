# Advanced Route Debugging

## Route Resolution Process

When a request arrives, Spry resolves it through this pipeline:

1. **Public asset check** — for GET or HEAD, with local static-file support or generated Netlify/Vercel hosting, serve a matching file from the configured `publicDir` (default: `public/`)
2. **Route resolution** — match the route and select the fallback if needed; create the `Event` with matched parameters
3. **Middleware chain** — run global middleware, then scoped middleware from broad to specific; each can short-circuit
4. **Handler execution** — when middleware reaches `next()`, execute the matched route or fallback
5. **Error chain** — if the route or fallback throws, run applicable error handlers from specific to general

Local file serving and inspection validate paths lexically and follow filesystem
symlinks. Use a trusted `publicDir` tree, including its symlink targets.

## Debugging Route Discovery Issues

### Verify the scanner found your route

Check the generated app file at `<outputDir>/src/app.dart` (default: `.spry/src/app.dart`). Look for your route path in the route map:

```dart
// The generated source imports the handler file with an alias.
import '../../routes/users/[id].get.dart' as $i0;

final app = Spry(
  routes: {
    '/users/:id': {HttpMethod.get: $i0.handler},
  },
);
```

### Common scanner issues

1. **File in wrong directory**: Routes must be in `routes/` (or the configured `routesDir`).
2. **Underscore prefix**: Files or directories starting with `_` are skipped by the scanner (except `_middleware.dart` and `_error.dart`).
3. **Non-Dart files**: Only `.dart` files are scanned.
4. **Invalid segment syntax**: Malformed `[...]` or `[[...]]` patterns produce a scanner error.

## Debugging Middleware Ordering

### Check the generated middleware chain

In `.spry/src/app.dart`, the middleware is wired in order:

```dart
final middleware = [
  // Runtime collection is broad to specific; globals precede scoped entries.
  MiddlewareRoute(path: '/**', handler: logger),
  MiddlewareRoute(path: '/**', handler: rootMiddleware),
  MiddlewareRoute(path: '/admin/**', handler: adminMiddleware),
];
```

### Verify with MCP

```text
spry.explain_route(method: "GET", path: "/admin/users")
```

The `middleware_chain` field shows the filesystem middleware order. The tool
cannot inspect middleware composed inside `defineHandler(middleware: ...)` or
other handler wrappers; check the matched handler source for those local
compositions. Public assets can bypass the filesystem chain entirely on
runtimes that support local static files. For generated Netlify and Vercel
workspaces, `public_asset.delivery: "platform_publish"` describes hosting-layer
asset precedence before the function rewrite, rather than a direct call to the
function endpoint. Custom hosting overrides require checking deployment config.

## Debugging Param Extraction

If route params are empty or wrong:

1. Check the route file's path pattern matches the request path
2. Verify param names match between the file name and `event.params` access
3. Regex constraints (`[id([0-9]+)]`) only affect matching, not extraction — the param is still captured as a string

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
