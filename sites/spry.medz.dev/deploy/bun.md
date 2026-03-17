---
title: Deploy → Bun
description: Target Bun when you want a JavaScript runtime with a compact deployment model and fast startup characteristics.
---

# Bun

Use `BuildTarget.bun` when you want a JS runtime with fast startup and a compact deployment model.

## Example config

<<< ../../../example/bun/spry.config.dart

## Good fit

- Bun-based self-hosting
- teams already operating Bun in production
- deployments where Bun is the preferred runtime contract

## Practical note

Bun is still just a target. The route layer, middleware, and config surface stay the same as every other Spry deployment.
