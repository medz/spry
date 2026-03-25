---
title: Configuration
description: Configure how Spry scans your project, serves locally, and emits runtime-specific output.
---

# Configuration

Spry uses `spry.config.dart` as the single place where runtime behavior is selected. Route files describe your server surface. Config describes how that server should be built and run.

## Minimal config

<<< ./snippets/quickstart/spry.config.dart

This file writes JSON that the Spry CLI reads during `spry serve` and `spry build`.

## API

The public entrypoint is `defineSpryConfig(...)`:

<<< ../../lib/config.dart{50-108}

## Core options

### `target`

Selects which runtime Spry should emit for.

Available values:

- `BuildTarget.vm` — Dart VM, no compilation
- `BuildTarget.exe` — native executable (`dart compile exe`)
- `BuildTarget.aot` — AOT snapshot
- `BuildTarget.jit` — JIT snapshot
- `BuildTarget.kernel` — kernel snapshot
- `BuildTarget.node` — Node.js
- `BuildTarget.bun` — Bun
- `BuildTarget.deno` — Deno
- `BuildTarget.cloudflare` — Cloudflare Workers
- `BuildTarget.vercel` — Vercel
- `BuildTarget.netlify` — Netlify Functions

This is the most important config field. Everything else should usually stay runtime-agnostic.

### `host`

Overrides the hostname used by `spry serve`.

```dart
defineSpryConfig(
  host: '127.0.0.1',
  target: BuildTarget.vm,
);
```

### `port`

Overrides the local port used by `spry serve`.

```dart
defineSpryConfig(
  port: 4000,
  target: BuildTarget.vm,
);
```

### `reload`

Controls how `spry serve` reloads during development.

Available values:

- `ReloadStrategy.restart`
- `ReloadStrategy.hotswap`

Use `hotswap` for targets such as Cloudflare Workers where keeping the runtime model aligned with the platform is useful.

## Project layout options

### `routesDir`

Changes the directory that Spry scans for route files.

```dart
defineSpryConfig(
  routesDir: 'server/routes',
  target: BuildTarget.node,
);
```

### `middlewareDir`

Changes the directory used for global middleware files.

```dart
defineSpryConfig(
  middlewareDir: 'server/middleware',
  target: BuildTarget.node,
);
```

### `publicDir`

Changes the static asset root. Spry checks this directory before it falls through to route handlers for `GET` and `HEAD` requests.

```dart
defineSpryConfig(
  publicDir: 'static',
  target: BuildTarget.vm,
);
```

## Build output options

### `outputDir`

Controls where Spry writes generated output.

```dart
defineSpryConfig(
  outputDir: 'dist/server',
  target: BuildTarget.node,
);
```

By default, Spry emits generated files into `.spry/`.

### `wranglerConfig`

Lets Cloudflare targets point at a custom Wrangler config file.

```dart
defineSpryConfig(
  target: BuildTarget.cloudflare,
  wranglerConfig: 'deploy/wrangler.toml',
  reload: ReloadStrategy.hotswap,
);
```

## OpenAPI

Spry can generate an OpenAPI 3.1 document during `spry build` and
`spry serve`.

Configuration lives in `defineSpryConfig(...)`, but the document objects are
imported from `package:spry/openapi.dart`.

For the full guide, including route-level metadata, merge strategy, and
webhooks, see [OpenAPI](/guide/openapi).

### Minimal `openapi` config

<<< ./snippets/reference/openapi/spry.config.dart

Important points:

- `OpenAPIConfig.document` is the document seed. `paths` are still generated
  from the route tree.
- `OpenAPIOutput.route('openapi.json')` writes the output into `public/`.
- `OpenAPIOutput.local(...)` can write to another project-relative path.
- `componentsMergeStrategy` defaults to `strict`.

### Route-level metadata

Route files can expose a top-level `openapi` value:

<<< ./snippets/reference/openapi/routes.index.dart

Spry resolves this value through the analyzer, so nested reusable top-level
spec values can live in shared files and be re-exported through user barrels.

### Route-level `globalComponents`

If a route needs to contribute shared schemas or callbacks to the final
document, use `globalComponents`:

<<< ./snippets/reference/openapi/routes.users_id.dart

These values are lifted into document-level `components` during generation.
They are not kept as operation-local fields in the final `openapi.json`.

### Method expansion rules

OpenAPI generation follows the Spry route model, with one deliberate exception
for `HEAD`:

- `routes/users/[id].dart` expands to `get`, `post`, `put`, `patch`, `delete`,
  and `options`.
- If the same path also has explicit method files such as
  `routes/users/[id].get.dart`, the explicit operation wins for that method.
- `HEAD` is only emitted when the route explicitly defines `.head.dart`.
- Spry may still fall back from `HEAD` to `GET` at runtime, but that fallback is
  not mirrored into OpenAPI.

### Components merge strategy

Spry supports two merge modes when document-level components and lifted
`globalComponents` collide:

- `OpenAPIComponentsMergeStrategy.strict`
  identical definitions are deduplicated; conflicting definitions fail the
  build.
- `OpenAPIComponentsMergeStrategy.deepMerge`
  recursively merges map-shaped component values; conflicting leaf values still
  fail the build.

Conflict errors include both the component key and the sources involved, so you
can tell whether the conflict came from `openapi.document.components` or from a
specific route file.

## Recommended mental model

- Put routing concerns in files under `routes/`.
- Put shared request behavior in `middleware/` and `_middleware.dart`.
- Put runtime choice in `target`.
- Put local dev and output behavior in `spry.config.dart`.

If a setting changes how requests are matched, it probably belongs in the file tree. If it changes how the generated app runs, it belongs in config.
