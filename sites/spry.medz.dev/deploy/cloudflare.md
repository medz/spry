---
title: Deploy → Cloudflare Workers
description: Use the Cloudflare target when you want an edge-oriented deployment model with worker-style runtime behavior.
---

# Cloudflare Workers

Cloudflare is the edge-oriented target in the Spry runtime matrix.

## Example config

<<< ../../../example/cloudflare/spry.config.dart

## Why it is different

- the runtime model is worker-shaped, not process-shaped
- `ReloadStrategy.hotswap` is usually the right development behavior
- `wranglerConfig` can point to a custom Wrangler file when you need one

## Good fit

- edge deployments
- Cloudflare-first infrastructure
- projects that want low-latency routing close to users
