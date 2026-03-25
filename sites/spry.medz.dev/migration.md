---
title: Migration Guide
description: Migration notes for upgrading between major Spry releases and routing models.
---

# Migration Guide

## Upgrade to v8.2

Spry 8.2 changes the generated output layout, renames the Dart runtime target,
and removes the wildcard-param alias that named catch-all routes used to
receive.

The breaking changes are:

- `BuildTarget.dart` is now `BuildTarget.vm`
- generated Dart source moved from `.spry/*.dart` to `.spry/src/*.dart`
- JS target entrypoints moved to deploy-facing filenames such as
  `.spry/node/index.cjs` and `.spry/cloudflare/index.js`
- named catch-all routes no longer mirror their value onto
  `event.params.wildcard`

### `BuildTarget.dart` -> `BuildTarget.vm`

Update your `spry.config.dart` target selection:

```dart
// Before
defineSpryConfig(target: BuildTarget.dart);

// After
defineSpryConfig(target: BuildTarget.vm);
```

### Generated output layout

If your deployment scripts or tooling execute generated files directly, update
their paths:

- `.spry/main.dart` -> `.spry/src/main.dart`
- `.spry/app.dart` -> `.spry/src/app.dart`
- `.spry/hooks.dart` -> `.spry/src/hooks.dart`
- `.spry/node/main.cjs` -> `.spry/node/index.cjs`
- `.spry/bun/main.js` -> `.spry/bun/index.js`
- `.spry/deno/main.js` -> `.spry/deno/index.js`
- `.spry/cloudflare/cloudflare.mjs` -> `.spry/cloudflare/index.js`

Spry 8.2 also adds native Dart build targets for direct deployment:

- `BuildTarget.exe`
- `BuildTarget.aot`
- `BuildTarget.jit`
- `BuildTarget.kernel`

### Named catch-all params

Named catch-all route params no longer mirror their value onto
`event.params.wildcard`. Read the remainder through the declared param name
instead:

```dart
// Before
final slug = event.params.wildcard;

// After
final slug = event.params.get('slug');
```

This applies to named catch-all filesystem routes such as
`routes/[...slug].dart`, which continue to map to `/**:slug`.

### What to verify after upgrading

1. Update `spry.config.dart` to use `BuildTarget.vm`.
2. Rebuild and re-check any deployment script, Dockerfile, or platform config
   that points at generated files under `.spry/`.
3. Replace `event.params.wildcard` with the declared catch-all param name in
   route handlers.

## Upgrade to v8

If you are already on the file-routing model introduced in Spry 7, the move to v8 is small but not zero-cost.

The breaking changes are:

- direct `Request` construction now follows the upstream Fetch-style init API
- direct `Response` construction now follows the upstream Fetch-style init API
- manual remainder route strings must use `/**` instead of `/*`

### Direct `Request` construction

If you construct exported `Request` values yourself, switch to `RequestInit`:

```dart
// Before
final request = Request(
  Uri.parse('https://example.com/users/42'),
  method: 'GET',
);

// After
final request = Request(
  Uri.parse('https://example.com/users/42'),
  RequestInit(method: HttpMethod.get),
);
```

### Direct `Response` construction

If you build `Response` values directly, move status and headers into `ResponseInit`:

```dart
// Before
return Response(
  status: 404,
  headers: {'content-type': 'application/json'},
  body: '{"error":"not_found"}',
);

// After
return Response(
  '{"error":"not_found"}',
  ResponseInit(
    status: 404,
    headers: {'content-type': 'application/json'},
  ),
);
```

Spry re-exports `RequestInit` and `ResponseInit` from `package:spry/spry.dart` and `package:spry/app.dart`, so most projects only need to update constructor calls.

### Manual string routes

If you manually construct `Spry`, `MiddlewareRoute`, or `ErrorRoute` with string paths, change remainder matches from `/*` to `/**`:

```dart
// Before
MiddlewareRoute(path: '/*', handler: requestLogger)
ErrorRoute(path: '/api/*', handler: apiError)

// After
MiddlewareRoute(path: '/**', handler: requestLogger)
ErrorRoute(path: '/api/**', handler: apiError)
```

Filesystem routes do not need a rename for this change. Spry will keep translating file names into the updated `roux` syntax for you.

### What to verify after upgrading

1. Re-run route matching tests if you use manual `Spry(...)` route maps.
2. Rebuild any helper code that manually creates `Request` or `Response` objects.
3. Check middleware and error scopes if they relied on `/*` remainder matching.

### New routing syntax you can opt into

v8 also adds richer filesystem route syntax. These are additive features, not migration requirements:

- regex params such as `[id([0-9]+)]`
- optional params such as `[[id]]`
- repeated params such as `[...path+]` and `[[...path]]`
- embedded params such as `post-[id].json`
- single-segment wildcards such as `[_]`

## Upgrade from v6 to v7

Spry 7 introduced a different center of gravity than older Spry guides. The framework moved to file routing, generated output, and runtime targets selected in config.

## The headline shift

Old docs were centered on:

- `createSpry()`
- imperative route registration such as `app.get(...)`
- group-based route composition
- standalone server examples written by hand

Spry 7 is centered on:

- `routes/` as the source of truth
- `spry build` and `spry serve`
- `defineSpryConfig(...)`
- a generated `Spry(...)` app and target-specific runtime entrypoint

## What to replace in v7

### Imperative route registration

If you previously wrote `app.get('/users/:id', handler);`, move that logic into `routes/users/[id].dart`.

### Route groups

If you relied on `app.group(...)`, stop modeling route structure in code. Use folders plus `_middleware.dart` for scope-level behavior.

### Manual server adapters

If your mental model was “I write the server wrapper myself”, move that concern into `spry.config.dart` and target selection.

### Request helpers

Prefer the request-scoped `Event` object:

- `event.request`
- `event.headers`
- `event.params`
- `event.locals`
- `event.context`

## A migration path that usually works

1. Move route logic into `routes/`.
2. Add `spry.config.dart`.
3. Replace shared wrappers with `middleware/` and scoped `_middleware.dart`.
4. Replace ad-hoc error translation with scoped `_error.dart`.
5. Run `dart run spry serve` and inspect the generated output.
