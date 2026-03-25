---
title: Deploy → Netlify
description: Use the Netlify target when you want Spry to emit a Netlify Functions workspace ready for deployment.
---

# Netlify

`BuildTarget.netlify` emits a complete Netlify Functions workspace under `.spry/netlify/`. Spry generates all platform bootstrap files — you deploy the workspace directly.

## Config

<<< ../../../example/netlify/spry.config.dart

`ReloadStrategy.hotswap` keeps the Netlify dev server alive across rebuilds.

## Build output

```text
.spry/
  src/
    main.dart               ← compile input
  netlify/
    runtime/
      main.js               ← compiled Dart-to-JS output
    functions/
      index.mjs             ← Netlify Function entry point
    netlify.toml            ← site config (generated if missing)
    public/                 ← copied public assets
```

`functions/index.mjs` is an ESM module that loads the compiled runtime and exports the `fetch` handler for Netlify Functions.

The generated `netlify.toml` configures the functions directory and a catch-all redirect so all requests route through the function:

```toml
[build]
publish = "public"

[functions]
directory = "functions"

[[redirects]]
from = "/*"
to = "/.netlify/functions/index"
status = 200
```

## Deploy

```bash
# Build
dart run spry build

# Deploy from the generated workspace
cd .spry/netlify
netlify deploy --prod
```

For CI deployment, keep your Build Command as `dart run spry build` and set Publish directory to `.spry/netlify/public` and Functions directory to `.spry/netlify/functions` in your Netlify site settings.

## Local dev

```bash
dart run spry serve
```

`spry serve` runs `netlify dev` inside `.spry/netlify/` automatically.

## Good fit

- Netlify-hosted server deployments
- Projects that want Netlify Functions rather than Edge Functions
- Teams that want Spry to own all platform wrapper files
