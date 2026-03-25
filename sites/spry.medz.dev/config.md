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

## Recommended mental model

- Put routing concerns in files under `routes/`.
- Put shared request behavior in `middleware/` and `_middleware.dart`.
- Put runtime choice in `target`.
- Put local dev and output behavior in `spry.config.dart`.

If a setting changes how requests are matched, it probably belongs in the file tree. If it changes how the generated app runs, it belongs in config.
