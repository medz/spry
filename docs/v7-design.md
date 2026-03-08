# Spry v7 Architecture Design

## Vision

Spry v7 is a file-routing HTTP framework for Dart. Routes are defined by files on disk, not by code. The underlying runtime is provided by [osrv](https://github.com/medz/osrv), making Spry apps portable across Dart native, Node.js, Bun, Cloudflare Workers, and Vercel.

```
osrv   →  runtime layer  (Dart / Node / Bun / Cloudflare / Vercel)
spry   →  design pattern (file-routing + middleware + event model + CLI)
```

---

## Package Structure

A single `spry` package that includes everything: the core framework, the CLI, and the code generator. No separate packages needed — Dart's tree-shaking removes any unused code at compile time.

```yaml
name: spry
executables:
  spry: bin/spry.dart

dependencies:
  ht: ^0.2.0        # Request, Response, Headers, FormData
  osrv: ^0.2.0      # Runtime (RequestContext, Runtime)
  roux: ^0.2.0      # Trie router
  coal: ^0.0.6      # CLI argument parsing
  watcher: ^1.x     # File watching (spry serve)
  path: ^1.x        # Path utilities
```

---

## Project Structure

```
my_app/
  pubspec.yaml
  spry.config.dart        # spry project configuration — optional
  hooks.dart              # osrv lifecycle hooks (onStart, onStop, onError) — optional
  middleware/
    01_logger.dart        # global middleware, applied in filename sort order
    02_cors.dart
    03_auth.dart
  routes/
    _middleware.dart      # scoped middleware for all routes and below
    _error.dart           # scoped error handler for all routes and below
    index.dart            # any method → /
    about.dart            # any method → /about
    about.get.dart        # GET only  → /about
    about.post.dart       # POST only → /about
    users/
      index.get.dart      # GET only  → /users
      index.post.dart     # POST only → /users
      [id].dart           # any method → /users/:id
      [id].get.dart       # GET only   → /users/:id
      [id]/
        posts.get.dart    # GET only   → /users/:id/posts
    api/
      _middleware.dart    # scoped middleware for /api/* routes
      _error.dart         # scoped error handler for /api/* routes
      health.get.dart     # GET only   → /api/health
    [...slug].dart        # catch-all fallback → /*
  lib/
    ...
  .spry/
    app.g.dart            # generated — do not edit
    main.dart             # generated — do not edit
```

---

## Root-level Convention Files

| Path                | Role                                                       |
|---------------------|------------------------------------------------------------|
| `spry.config.dart`  | Project configuration: runtime, directories, build, dev   |
| `hooks.dart`        | osrv lifecycle hooks: `onStart`, `onStop`, `onError`       |
| `middleware/`       | Global middleware directory, each file is one middleware   |

All are optional and sit at the project root, siblings to `routes/`.

The global fallback for unmatched routes is handled by `routes/[...slug].dart` like any other catch-all route.

---

## `spry.config.dart` — Project Configuration

`spry.config.dart` is a Dart executable that calls `defineSpryConfig()` inside `main()`. The CLI runs this file to resolve the active configuration. Because it is plain Dart code, config values can be derived dynamically (e.g. from environment variables).

All fields passed to `defineSpryConfig` are optional. Omitting `spry.config.dart` entirely is also valid — in that case `loadConfig()` skips process execution and starts from built-in defaults before applying CLI overrides.

```dart
// spry.config.dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    // Runtime configuration
    host: '0.0.0.0',
    port: 3000,
    target: BuildTarget.dart,        // dart | node | bun | cloudflare | vercel

    // Directory overrides
    routesDir: 'routes',
    middlewareDir: 'middleware',

    // Build options
    outputDir: '.spry',
    compileArgs: [],                 // extra args forwarded to dart compile

    // Dev options
    reload: ReloadStrategy.restart,  // restart | hotswap
  );
}
```

Internally, `defineSpryConfig` serializes all parameters to a JSON contract and writes it to stdout. The CLI runs `dart run spry.config.dart`, captures stdout, parses the JSON, then applies any CLI argument overrides on top.

```dart
// defineSpryConfig internals (simplified)
void defineSpryConfig({...}) {
  print(jsonEncode({
    'target': target.name,  // 'dart' | 'node' | 'bun' | 'cloudflare' | 'vercel'
    'host': host,
    'port': port,
    'routesDir': routesDir,
    'middlewareDir': middlewareDir,
    'outputDir': outputDir,
    'compileArgs': compileArgs,
    'reload': reload.name,
  }));
}
```

`loadConfig()` in `package:spry/builder.dart` encapsulates this process:

```dart
// 1. dart run spry.config.dart  → stdout JSON
// 2. parse JSON                 → base config
// 3. apply overrides            → final BuildConfig
Future<BuildConfig> loadConfig({Map<String, dynamic> overrides = const {}});
```

### `BuildTarget`

| Value         | Compile output              | osrv runtime           |
|---------------|-----------------------------|------------------------|
| `dart`        | `dart compile exe`          | `DartRuntimeConfig`    |
| `node`        | `dart compile js`           | `NodeRuntimeConfig`    |
| `bun`         | `dart compile js`           | `BunRuntimeConfig`     |
| `cloudflare`  | `dart compile js` (ESM)     | osrv Cloudflare entry  |
| `vercel`      | `dart compile js` (ESM)     | osrv Vercel entry      |

### `ReloadStrategy`

| Value       | Behaviour                                              |
|-------------|--------------------------------------------------------|
| `restart`   | Full `dart run` restart on every file change (default) |
| `hotswap`   | Isolate-level hot-swap (faster, experimental)          |

---

## Middleware Layers

Middleware is applied in this order for every request:

```
1. middleware/*.dart            (global, applied in filename sort order)
2. routes/_middleware.dart      (scoped to all routes)
3. routes/api/_middleware.dart  (scoped to /api/*, if matched)
4. route handler
```

Each layer wraps the next, outermost first.

### `middleware/` — Global Middleware Directory

Each file exports a single `middleware` function. Files are applied in ascending filename sort order.

```dart
// middleware/01_logger.dart
import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  print('${event.method} ${event.url}');
  final response = await next();
  print('→ ${response.status}');
  return response;
}
```

No central registration file — adding or removing a file in `middleware/` is enough.

### `routes/**/_middleware.dart` — Scoped Middleware

Exports a single `middleware` function, applied only to routes in that directory and below.

```dart
// routes/api/_middleware.dart
import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  return next();
}
```

### Request Matching Model

Spry uses three distinct matching strategies at runtime:

1. **Handler lookup** — match exactly one route for `method + path`
2. **Middleware lookup** — collect all matching middleware scopes from outer to inner
3. **Error lookup** — collect matching error boundaries from inner to outer, using the nearest one first

These strategies are intentionally different and must not share the same execution semantics.

#### Handler Lookup

- Match the single best route for `method + path`
- Apply method-specific-over-generic precedence
- `HEAD` first matches `'HEAD'`; if absent, it falls back to `'GET'`
- Fall back to the catch-all route only if no concrete route matches

#### Middleware Lookup

- Collect every matching middleware scope for the request path
- Execute them from outer to inner
- `MiddlewareRoute.path` uses roux route syntax, not an exact URL literal
- `MiddlewareRoute.method == null` means any-method middleware
- For a request method such as `GET`, collect both `null` and `'GET'`
- Ordering is deterministic: less specific path first, and within the same path any-method before method-specific
- Example: for `/api/demo`, middleware registered for `/*` and `/api/*` both apply

#### Error Lookup

- Start from the most specific matching error boundary for the request path
- `ErrorRoute.path` also uses roux route syntax
- `ErrorRoute.method == null` means any-method error boundary
- For a request method such as `GET`, the candidate stack includes both `null` and `'GET'`
- Ordering is deterministic: more specific path first, and within the same path method-specific before any-method
- If that error handler returns a response, stop
- If that error handler throws, continue to the next outer error boundary
- If no scoped error handler handles the error, fall back to `hooks.dart`'s `onError`
- If that is also absent or throws, delegate to osrv's default error handling

### Registration Semantics

Duplicate policy is resolved at registration time, not at match time.

- `Spry.routes` entries are keyed by normalized path, and each path stores a `Map<String?, Handler>`
- `MiddlewareRoute` entries are keyed by `method + path + registration order`
- `ErrorRoute` entries are keyed by `method + path + registration order`
- Matching only operates on the effective registered entries; it never decides between duplicate registrations on the fly

This keeps Spry's local adapter consistent with roux today, and allows a direct switch later if roux adds native duplicate-policy and multi-match support.

### Request Execution Algorithm

At runtime, `Spry.fetch` should follow this sequence:

```dart
Future<Response> fetch(Request request) async {
  final handlerMatch = switch (request.method) {
    'HEAD' => matchHandler('HEAD', request.url.path) ??
        matchHandler('GET', request.url.path),
    String method => matchHandler(method, request.url.path) ??
        matchHandler(null, request.url.path),
  };

  if (handlerMatch == null) {
    return Response(status: 404);
  }

  final middlewareMatches = collectMiddleware(
    method: request.method,
    path: request.url.path,
  );

  final errorMatches = collectErrors(
    method: request.method,
    path: request.url.path,
  );

  final event = Event(
    request: request,
    params: handlerMatch.params,
  );

  Future<Response> invokeHandler() async {
    return resolveResponse(await handlerMatch.handler(event));
  }

  Future<Response> invokeWithErrorBoundaries() async {
    try {
      return await invokeHandler();
    } catch (error, stack) {
      return await handleError(error, stack, event, errorMatches);
    }
  }

  Next next = invokeWithErrorBoundaries;

  for (final match in middlewareMatches.reversed) {
    final prev = next;
    next = () async {
      return await match.handler(event, prev);
    };
  }

  return await next();
}
```

Supporting rules:

- `matchHandler` returns a single best match
- `collectMiddleware` returns outer-to-inner matches and includes both any-method and exact-method entries
- `collectErrors` returns inner-to-outer candidates and includes both exact-method and any-method entries
- `handleError` tries each scoped `ErrorRoute` candidate in order; if one throws, continue to the next
- If all scoped `ErrorRoute` handlers fail or none match, call `hooks.dart`'s `onError`
- If `hooks.dart`'s `onError` is absent or throws, defer to osrv's default error handling

---

## File Routing Conventions

### Route File Resolution

For a request `METHOD /path`, the router resolves in this priority order:

1. **Method-specific file** — `<name>.<method>.dart` (e.g. `about.get.dart` for `GET /about`)
2. **Generic file** — `<name>.dart` (handles any method for that path)
3. **Catch-all** — `routes/[...slug].dart` if present

If none match, Spry returns `404 Not Found`.

### Filename → URL Pattern

| File path                          | Method | URL pattern        |
|------------------------------------|--------|--------------------|
| `routes/index.dart`                | any    | `/`                |
| `routes/index.get.dart`            | GET    | `/`                |
| `routes/about.dart`                | any    | `/about`           |
| `routes/about.get.dart`            | GET    | `/about`           |
| `routes/about.post.dart`           | POST   | `/about`           |
| `routes/users/index.dart`          | any    | `/users`           |
| `routes/users/[id].dart`           | any    | `/users/:id`       |
| `routes/users/[id].get.dart`       | GET    | `/users/:id`       |
| `routes/users/[id]/posts.get.dart` | GET    | `/users/:id/posts` |
| `routes/[...slug].dart`            | any    | `/*` (catch-all, `params['slug']`)  |
| `routes/[...].dart`                | any    | `/*` (catch-all, `params.wildcard`) |

Files and directories prefixed with `_` are **not** treated as routes.

### Special Files inside `routes/`

| Filename           | Role                                              |
|--------------------|---------------------------------------------------|
| `_middleware.dart` | Scoped middleware for that directory and below    |
| `_error.dart`      | Scoped error handler for that directory and below |

### Match Precedence

Spry resolves matches in this order:

1. More specific paths beat less specific paths: static segment > dynamic segment > catch-all.
2. For the same normalized path, method-specific files beat generic files.
3. The root catch-all route (`routes/[...slug].dart` or `routes/[...].dart`) is only used after no concrete route matches.

### Scan Validation

The scanner must reject invalid route trees before code generation:

- A normalized `method + path` may only be declared once.
- `routes/foo.dart` and `routes/foo/index.dart` are a conflict because both normalize to the same path.
- A directory may define at most one catch-all route file: either `[...name].dart` or `[...].dart`, not both.
- Catch-all segments must be terminal. Files such as `routes/[...slug]/index.dart` are invalid.
- Generic and method-specific files for the same path are allowed, because method-specific files override the generic handler only for that HTTP method.
- If multiple files normalize to the same path shape, their dynamic segment names must agree. `routes/users/[id].dart` and `routes/users/[userId].get.dart` are invalid together because they would expose different param keys for the same route.
- File-routing is always strict for conflicting catch-all routes. Spry does not downgrade `[...name].dart` vs `[...].dart` conflicts to warnings because param ownership would become ambiguous.

---

## Handler API

### Route Files — `handler(Event event)`

Every route file exports a single top-level `handler` function. The HTTP method is encoded in the filename. The function may be synchronous or asynchronous; generated code normalizes the return value through Spry's response resolver.

Route files do **not** export route-local `onError` or raw osrv `fetch` in v7. Error boundaries are defined by `_error.dart` files and root `hooks.dart`; raw osrv fetch hooks would bypass Spry's `Event`, middleware, and response-coercion model.

```dart
import 'dart:async';

typedef Handler = FutureOr<Object?> Function(Event event);
```

```dart
// routes/about.get.dart
import 'package:spry/spry.dart';

String handler(Event event) => 'About page';
```

```dart
// routes/users/[id].get.dart
import 'package:spry/spry.dart';

Future<Map<String, Object?>> handler(Event event) async {
  final id = event.params['id'];
  return {'id': id};
}
```

```dart
// routes/[...slug].dart  (catch-all fallback)
import 'package:spry/spry.dart';

Response handler(Event event) => Response(status: 404);
```

### Return Types

| Awaited return type | Behavior               |
|---------------------|------------------------|
| `Response`          | Sent as-is             |
| `String`            | `200 text/plain`       |
| `Map` / `List`      | `200 application/json` |
| `null` / `void`     | `404 Not Found`        |

The same coercion rules apply to the awaited value of any `Future<T>`.

---

## `hooks.dart` — Server Lifecycle

`hooks.dart` exports top-level functions that map directly to osrv's `Server` lifecycle hooks. All are optional.

```dart
// hooks.dart
import 'dart:async';
import 'package:osrv/osrv.dart';

Future<void> onStart(ServerLifecycleContext context) async {
  print('Server started on ${context.runtime.name}');
}

Future<void> onStop(ServerLifecycleContext context) async {
  print('Server shutting down');
}

FutureOr<Object?> onError(
  Object error,
  StackTrace stack,
  ServerLifecycleContext context,
) async {
  return Response.json({'error': error.toString()}, status: 500);
}
```

The generated entry point assembles these into the osrv `Server`:

```dart
// .spry/main.dart (generated)
import 'package:osrv/osrv.dart';
import 'package:osrv/runtime/dart.dart';
import 'hooks.g.dart' as $hooks;
import 'app.g.dart';

void main() async {
  final server = Server(
    fetch: app.fetch,
    onStart: $hooks.onStart,
    onStop: $hooks.onStop,
    onError: $hooks.onError,
  );
  await serve(server, DartRuntimeConfig(host: '0.0.0.0', port: 3000));
}
```

---

## Event Object

```dart
class Event {
  /// The incoming HTTP request (ht.Request).
  final Request request;

  /// Route parameters extracted from the URL pattern.
  final RouteParams params;

  /// Per-request key-value store for sharing data across middleware and handlers.
  final Locals locals;

  /// The osrv RequestContext — runtime info, waitUntil, runtime extensions.
  final RequestContext context;

  // Convenience getters
  String get method;
  Uri get url;
  Headers get headers;
}
```

## RouteParams

`RouteParams` is a zero-cost `extension type` over `Map<String, String>`. It wraps roux's raw params map and provides a typed API with no runtime overhead.

```dart
extension type RouteParams(Map<String, String> _) implements Map<String, String> {
  /// Returns the param value, or null if absent.
  String? get(String name) => _[name];

  /// Returns the param value, throws [StateError] if absent.
  String required(String name) =>
      _[name] ?? (throw StateError('Missing route param: "$name"'));

  /// Parses the param as an [int].
  int int(String name) => core.int.parse(required(name));

  /// Parses the param as a [num].
  num num(String name) => core.num.parse(required(name));

  /// Parses the param as a [double].
  double double(String name) => core.double.parse(required(name));

  /// Decodes the param into [T] using a custom [decoder].
  T decode<T>(String name, T Function(String value) decoder) =>
      decoder(required(name));

  /// Parses the param as an enum from [values].
  T $enum<T extends Enum>(String name, List<T> values) =>
      decode(name, (v) => values.firstWhere(
            (e) => e.name == v,
            orElse: () => throw StateError(
              'Invalid value "$v" for param "$name". '
              'Expected: ${values.map((e) => e.name).join(', ')}',
            ),
          ));

  /// Returns the catch-all wildcard value.
  /// If the route file is named [...slug].dart, use params.get('slug') instead.
  /// Falls back to roux's internal 'wildcard' key for unnamed [...].dart routes.
  String? get wildcard => _['wildcard'];
}
```

Usage:

```dart
event.params.get('id')                        // String?
event.params.required('id')                   // String
event.params.int('page')                      // int
event.params.double('ratio')                  // double
event.params.$enum('role', UserRole.values)   // UserRole
event.params.decode('date', DateTime.parse)   // DateTime
event.params.get('slug')                      // [...slug].dart — named wildcard
event.params.wildcard                         // [...].dart — unnamed wildcard
```

---

### Locals

```dart
// In middleware
event.locals.set(#user, await authenticate(event));

// In handler
final user = event.locals.get<User>(#user);
```

---

## Error Handler API

```dart
// routes/_error.dart
import 'package:spry/spry.dart';

FutureOr<Object?> onError(Object error, StackTrace stack, Event event) async {
  return Response.json({'error': error.toString()}, status: 500);
}
```

Errors propagate to the nearest `_error.dart` in scope first. If that handler throws, Spry retries with the next outer `_error.dart`. If none exists, `hooks.dart`'s `onError` applies. If that is also absent, or it throws, osrv's default error handling applies.

Scoped error handlers are emitted into a separate error table. For example, `routes/api/health.get.dart` first uses `routes/api/_error.dart`, then falls back to `routes/_error.dart`, then `hooks.dart`'s `onError`.

---

## CLI

CLI arguments always take precedence over values defined in `spry.config.dart`. The resolution order is:

```
CLI args  >  spry.config.dart  >  built-in defaults
```

### `spry serve`

```
spry serve [--port <port>] [--host <host>] [--routes <dir>] [--middleware <dir>] [--reload restart|hotswap]
```

Steps:
1. Run `dart run spry.config.dart` to resolve config; apply CLI arg overrides.
   If `spry.config.dart` does not exist, start from built-in defaults instead.
2. Scan `middleware/`, `routes/`, `hooks.dart`.
3. Generate `.spry/app.g.dart` and `.spry/main.dart`.
4. Launch `dart run .spry/main.dart`.
5. Watch for file changes → regenerate → restart (or hotswap per config).

### `spry build`

```
spry build [--target dart|node|bun|cloudflare|vercel] [--output <dir>] [--routes <dir>] [--middleware <dir>]
```

Steps:
1. Run `dart run spry.config.dart` to resolve config; apply CLI arg overrides.
   If `spry.config.dart` does not exist, start from built-in defaults instead.
2. Scan `middleware/`, `routes/`, `hooks.dart`.
3. Generate `.spry/app.g.dart` — generated app definition, all handlers statically imported.
4. Generate `.spry/main.dart` — entry point wired to the selected osrv runtime.
5. Compile:
   - `dart` → `dart compile exe .spry/main.dart`
   - `node` / `bun` → `dart compile js .spry/main.dart`
   - `cloudflare` / `vercel` → `dart compile js` with osrv ESM entry

---

## Generated Code

### `.spry/app.g.dart`

The generator emits a `Spry` application definition, not a standalone router abstraction. `Spry` materializes three internal roux registries:

- one router for request handlers
- one router for middleware chaining
- one router for scoped error boundaries

The generator resolves inherited middleware and error scopes before emitting routes. Handler registration is emitted as direct method maps under `Spry.routes`. Scoped middleware and scoped errors are emitted into separate tables so shared scopes are not duplicated across routes.

Spry may initially implement middleware and error scope collection with a local adapter over roux. Once roux exposes a native multi-match API for scope stacking, Spry can switch to it without changing the generated app shape.

```dart
// Generated by spry — do not edit.
import 'package:spry/app.dart';
import '../middleware/01_logger.dart' as $m0;
import '../middleware/02_cors.dart' as $m1;
import '../middleware/03_auth.dart' as $m2;
import '../routes/_middleware.dart' as $root_middleware;
import '../routes/_error.dart' as $root_error;
import '../routes/api/_middleware.dart' as $api_middleware;
import '../routes/api/_error.dart' as $api_error;
import '../routes/api/health.get.dart' as $api_health_get;
import '../routes/index.dart' as $index;
import '../routes/about.dart' as $about;
import '../routes/about.get.dart' as $about_get;
import '../routes/about.post.dart' as $about_post;
import '../routes/users/index.get.dart' as $users_get;
import '../routes/users/[id].get.dart' as $users_id_get;
import '../routes/[...slug].dart' as $catchall;

final app = Spry(
  routes: {
    '/': {
      null: $index.handler,
    },
    '/about': {
      null: $about.handler,
      'GET': $about_get.handler,
      'POST': $about_post.handler,
    },
    '/users': {
      'GET': $users_get.handler,
    },
    '/users/:id': {
      'GET': $users_id_get.handler,
    },
    '/api/health': {
      'GET': $api_health_get.handler,
    },
  },
  middleware: [
    MiddlewareRoute(path: '/*', handler: $m0.middleware),
    MiddlewareRoute(path: '/*', handler: $m1.middleware),
    MiddlewareRoute(path: '/*', handler: $m2.middleware),
    MiddlewareRoute(path: '/*', handler: $root_middleware.middleware),
    MiddlewareRoute(path: '/api/*', handler: $api_middleware.middleware),
  ],
  errors: [
    ErrorRoute(path: '/*', handler: $root_error.onError),
    ErrorRoute(path: '/api/*', handler: $api_error.onError),
  ],
  fallback: {
    null: $catchall.handler,
  },
);
```

Conceptually, the runtime-facing API is:

```dart
typedef RouteHandlers = Map<String?, Handler>;

class Spry {
  final Map<String, RouteHandlers> routes;
  final RouteHandlers? fallback;
}

class MiddlewareRoute {
  /// A roux route pattern, e.g. '/*' or '/api/*'.
  final String path;
  /// `null` means any method.
  final String? method;
  final Middleware handler;
}

class ErrorRoute {
  /// A roux route pattern, e.g. '/*' or '/api/*'.
  final String path;
  /// `null` means any method.
  final String? method;
  final ErrorHandler handler;
}
```

### `.spry/hooks.g.dart`

`hooks.dart` is optional, but `.spry/hooks.g.dart` is always generated. It provides a stable import target for `.spry/main.dart`:

- If `hooks.dart` exists, it forwards `onStart`, `onStop`, and `onError`.
- If `hooks.dart` is absent, it exports `null` stubs for those hooks.

### `.spry/main.dart` — per target

The generated entry point varies by build target, following osrv conventions exactly.

**`dart` target** — native executable:
```dart
// Generated by spry — do not edit.
import 'package:osrv/osrv.dart';
import 'package:osrv/runtime/dart.dart';
import 'hooks.g.dart' as $hooks;
import 'app.g.dart';

Future<void> main() async {
  final server = Server(
    fetch: app.fetch,
    onStart: $hooks.onStart,
    onStop: $hooks.onStop,
    onError: $hooks.onError,
  );
  final runtime = await serve(server, DartRuntimeConfig(host: '0.0.0.0', port: 3000));
  await runtime.closed;
}
```

**`node` target** — compiled to JS, served via Node.js:
```dart
// Generated by spry — do not edit.
import 'package:osrv/osrv.dart';
import 'package:osrv/runtime/node.dart';
import 'hooks.g.dart' as $hooks;
import 'app.g.dart';

Future<void> main() async {
  final server = Server(
    fetch: app.fetch,
    onStart: $hooks.onStart,
    onStop: $hooks.onStop,
    onError: $hooks.onError,
  );
  final runtime = await serve(server, NodeRuntimeConfig(host: '0.0.0.0', port: 3000));
  await runtime.closed;
}
```

**`bun` target** — compiled to JS, served via Bun:
```dart
// Generated by spry — do not edit.
import 'package:osrv/osrv.dart';
import 'package:osrv/runtime/bun.dart';
import 'hooks.g.dart' as $hooks;
import 'app.g.dart';

Future<void> main() async {
  final server = Server(
    fetch: app.fetch,
    onStart: $hooks.onStart,
    onStop: $hooks.onStop,
    onError: $hooks.onError,
  );
  final runtime = await serve(server, BunRuntimeConfig(host: '0.0.0.0', port: 3000));
  await runtime.closed;
}
```

**`cloudflare` target** — ESM fetch entry, thin layer via `defineFetchEntry`:
```dart
// Generated by spry — do not edit.
import 'package:osrv/esm.dart';
import 'hooks.g.dart' as $hooks;
import 'app.g.dart';

void main() {
  final server = Server(
    fetch: app.fetch,
    onStart: $hooks.onStart,
    onStop: $hooks.onStop,
    onError: $hooks.onError,
  );
  defineFetchEntry(server, runtime: FetchEntryRuntime.cloudflare);
}
```

**`vercel` target** — ESM fetch entry, thin layer via `defineFetchEntry`:
```dart
// Generated by spry — do not edit.
import 'package:osrv/esm.dart';
import 'hooks.g.dart' as $hooks;
import 'app.g.dart';

void main() {
  final server = Server(
    fetch: app.fetch,
    onStart: $hooks.onStart,
    onStop: $hooks.onStop,
    onError: $hooks.onError,
  );
  defineFetchEntry(server, runtime: FetchEntryRuntime.vercel);
}
```

---

## Library Exports

### `package:spry/spry.dart`

Used in route files, middleware, and `hooks.dart`.

```dart
// Spry core
export 'src/event.dart';         // Event
export 'src/locals.dart';        // Locals
export 'src/route_params.dart';  // RouteParams
export 'src/types.dart';         // Next, Handler, Middleware

// Re-export ht (users don't need to depend on ht directly)
export 'package:ht/ht.dart';

// Re-export osrv types needed in hooks.dart
export 'package:osrv/osrv.dart'
    show RequestContext, ServerLifecycleContext, RuntimeInfo, RuntimeCapabilities;
```

### `package:spry/config.dart`

Used only in `spry.config.dart`.

```dart
export 'src/config.dart'; // defineSpryConfig, SpryConfig, BuildTarget, ReloadStrategy
```

### `package:spry/app.dart`

Used in generated `.spry/app.g.dart` and for advanced programmatic app construction.

```dart
export 'src/app.dart';              // Spry
export 'src/middleware_route.dart'; // MiddlewareRoute
export 'src/error_route.dart';      // ErrorRoute
```

### `package:spry/builder.dart`

Used by the spry CLI and downstream tools. Exposes three pure functions; writing files to disk is the caller's responsibility.

```dart
export 'src/builder/config.dart';     // BuildConfig, loadConfig()
export 'src/builder/route_tree.dart'; // RouteTree, RouteNode, RouteNodeKind
export 'src/builder/scanner.dart';    // scan()
export 'src/builder/generator.dart';  // GeneratedFile, generate()
```

#### Three capabilities

```dart
/// 1. Resolve config: runs spry.config.dart, parses stdout JSON, applies overrides.
Future<BuildConfig> loadConfig({Map<String, dynamic> overrides = const {}});

/// 2. Scan project files into a route tree.
Future<RouteTree> scan(BuildConfig config);

/// 3. Generate file contents from the route tree.
///    Returns a list of files — does NOT write to disk.
Future<List<GeneratedFile>> generate(RouteTree tree, BuildConfig config);
```

```dart
class GeneratedFile {
  final String path;    // relative to outputDir, e.g. 'app.g.dart'
  final String content; // file contents as a string
}
```

Downstream usage:

```dart
import 'package:spry/builder.dart';

final config = await loadConfig();
final tree   = await scan(config);
final files  = await generate(tree, config);
// do whatever: write to disk, inspect, transform, generate extras...
```

---

## Decisions

- **`middleware/` sort order** — filename lexicographic sort.
- **Global fallback** — `routes/[...slug].dart` catch-all route, consistent with normal routing.
- **Lifecycle hooks** — `hooks.dart` at project root, maps directly to osrv `Server` hooks.
- **Project config** — `spry.config.dart` is an executable entry that calls `defineSpryConfig()`; omitting the file is valid and falls back to built-in defaults.
- **Reload strategy** — configurable via `ReloadStrategy` in `spry.config.dart`; defaults to `restart`.
- **RouteParams** — zero-cost `extension type` over `Map<String, String>` with `get`, `required`, `int`, `num`, `double`, `decode`, `$enum`, `wildcard`.
- **Hooks loading** — `.spry/hooks.g.dart` is always generated so `.spry/main.dart` never conditionally imports `hooks.dart`.
- **Route validation** — the scanner rejects duplicate normalized routes, conflicting path shapes, and invalid catch-all placement before generation.
- **Route API** — `Spry.routes` is `Map<String, Map<String?, Handler>>`; method keys use wire-format strings like `'GET'` / `'POST'`, and `null` represents the generic fallback for that path.
- **HEAD behavior** — explicit `'HEAD'` registration is allowed; otherwise `HEAD` falls back to `'GET'`.
- **Generated app model** — generated code imports `package:spry/app.dart` and constructs a `Spry` app from declarative route method maps plus `MiddlewareRoute` and `ErrorRoute` objects; `Spry` then normalizes them into separate handler, middleware, and error roux registries internally.
- **Registration semantics** — duplicate behavior is resolved during registration; matching only sees the effective registered entries.
- **Middleware method semantics** — middleware collection includes both any-method and exact-method entries; ordering is outer-to-inner, with any-method before exact-method at the same path.
- **Error semantics** — scoped errors are nearest-first boundaries, not middleware-like chains; if a scoped error handler throws, Spry falls back to the next outer boundary.
