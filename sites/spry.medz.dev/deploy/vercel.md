---
title: Deploy → Vercel
description: Use the Vercel target when you want Spry to emit the full Vercel Functions workspace ready for deployment.
---

# Vercel

`BuildTarget.vercel` emits a complete Vercel Functions workspace under `.spry/vercel/`. Spry generates all the wrapper files required by the platform — you deploy the workspace as-is.

## Config

<<< ../../../example/vercel/spry.config.dart

`ReloadStrategy.hotswap` keeps the Vercel dev server alive across rebuilds.

## Build output

```text
.spry/
  src/
    main.dart               ← compile input
  vercel/
    runtime/
      main.js               ← compiled Dart-to-JS output
    api/
      index.mjs             ← Vercel Function entry point
    vercel.json             ← rewrite rules (generated if missing)
    package.json            ← @vercel/functions dependency
    public/                 ← copied public assets
```

`api/index.mjs` is a thin ESM wrapper that loads the compiled runtime and re-exports the `fetch` handler in the shape Vercel expects.

`vercel.json` is generated with a catch-all rewrite to `/api` so all requests are handled by the function:

```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/api" }]
}
```

## Deploy

```bash
# Build
dart run spry build

# Deploy from the generated workspace
cd .spry/vercel
vercel deploy
```

Or configure Vercel CI to use `.spry/vercel` as the project root, and let it deploy on push.

## Local dev

```bash
dart run spry serve
```

`spry serve` runs `vercel dev` inside `.spry/vercel/` automatically, including installing `@vercel/functions` on first run.

## Good fit

- Vercel-hosted server deployments
- Teams that want zero platform glue code in their repository
- Projects deploying both static assets and a server function on Vercel
