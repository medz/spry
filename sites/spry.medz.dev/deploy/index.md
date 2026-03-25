---
title: Deploy Overview
description: Pick a runtime target, build the generated output, and deploy the result using the platform-specific flow.
---

# Deploy Overview

Spry deployment is target-driven. You pick a runtime in `spry.config.dart`, run `spry build`, and get deployable output shaped for that platform.

## How it works

The build pipeline has two phases:

1. **Generate** — Spry scans your routes, middleware, and hooks, then emits Dart source files into `.spry/src/`.
2. **Compile** — For JS targets, Dart compiles `src/main.dart` to JavaScript. For native Dart targets, it compiles to a binary or snapshot.

You deploy the result under `.spry/` to your platform. Your application code in `routes/` never changes between targets.

## Targets

| Target | Type | Good for |
|---|---|---|
| [`vm`](/deploy/dart) | Dart VM (no compile) | Self-hosted, Dart-native environments |
| [`exe`](/deploy/dart#exe) | Native executable | Production self-hosted, Docker |
| [`aot`](/deploy/dart#aot) | AOT snapshot | Faster startup than JIT in Dart-hosted envs |
| [`jit`](/deploy/dart#jit) | JIT snapshot | Warm startup, portable across Dart VMs |
| [`kernel`](/deploy/dart#kernel) | Kernel snapshot | Portable, requires Dart SDK at runtime |
| [`node`](/deploy/node) | Node.js | Node-hosted platforms, traditional server hosting |
| [`bun`](/deploy/bun) | Bun | Bun-based self-hosting |
| [`deno`](/deploy/deno) | Deno | Deno-hosted environments, Deno Deploy |
| [`cloudflare`](/deploy/cloudflare) | Cloudflare Workers | Edge deployments, Cloudflare-first infra |
| [`vercel`](/deploy/vercel) | Vercel | Vercel-hosted server deployments |
| [`netlify`](/deploy/netlify) | Netlify Functions | Netlify-hosted deployments |

## Common flow

```bash
# 1. Set target in spry.config.dart
# 2. Build
dart run spry build

# 3. Deploy the generated output for your target
```

## Output layout

All targets write generated source into `.spry/src/`. Compiled output lands in a target-specific directory alongside it:

```text
.spry/
  src/           ← Generated Dart source (all targets)
    app.dart
    hooks.dart
    main.dart
  node/          ← node target output
  bun/           ← bun target output
  deno/          ← deno target output
  cloudflare/    ← cloudflare target output
  vercel/        ← vercel workspace
  netlify/       ← netlify workspace
  dart/          ← native compilation output (exe/aot/jit/kernel)
```

## Rule of thumb

Keep route code runtime-agnostic. Push runtime choice into `spry.config.dart`. The target-specific pages cover only the last-mile deployment steps.
