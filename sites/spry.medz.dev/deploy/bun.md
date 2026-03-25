---
title: Deploy → Bun
description: Target Bun when you want a JavaScript runtime with fast startup and a compact deployment model.
---

# Bun

`BuildTarget.bun` compiles your Spry application to a single JavaScript file optimised for the Bun runtime.

## Config

<<< ../../../example/bun/spry.config.dart

## Build output

```text
.spry/
  src/
    main.dart       ← compile input
  bun/
    index.js        ← compiled output, run directly with bun
```

## Build and run

```bash
dart run spry build
bun .spry/bun/index.js
```

## Production deployment

Copy `.spry/bun/index.js` and your `public/` assets to the server. No Dart SDK or intermediate wrapper needed.

```bash
bun index.js
```

## Good fit

- Bun-based self-hosting
- Teams already running Bun in production
- Deployments where startup time matters
