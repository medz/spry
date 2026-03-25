---
title: Deploy → Cloudflare Workers
description: Use the Cloudflare target when you want an edge-oriented deployment with worker-style runtime behavior.
---

# Cloudflare Workers

`BuildTarget.cloudflare` compiles your Spry application to a Cloudflare Worker. The build emits a compiled JavaScript bundle and a thin ESM wrapper that exports the standard `fetch` handler.

## Config

<<< ../../../example/cloudflare/spry.config.dart

`ReloadStrategy.hotswap` keeps the Wrangler dev server alive across rebuilds instead of restarting it.

## Build output

```text
.spry/
  src/
    main.dart           ← compile input
  cloudflare/
    main.js             ← compiled Dart-to-JS output
    index.js            ← ESM worker entry (export default { fetch })
```

## Wrangler setup

Point your `wrangler.toml` at the generated entry:

```toml
name = "my-app"
main = ".spry/cloudflare/index.js"

[assets]
directory = "public"
```

Spry validates this path during `spry build` and warns if it does not match.

## Build and deploy

```bash
# Build
dart run spry build

# Local dev
bunx wrangler dev

# Deploy to Cloudflare
bunx wrangler deploy
```

## Custom wrangler config path

If your Wrangler config is not at the project root, set `wranglerConfig` in `spry.config.dart`:

```dart
defineSpryConfig(
  target: BuildTarget.cloudflare,
  wranglerConfig: 'config/wrangler.toml',
);
```

## Good fit

- Edge deployments
- Cloudflare-first infrastructure
- Projects that want low-latency routing close to users
