---
title: Deploy Overview
description: Pick a runtime target, build the generated output, and deploy the result using the platform-specific flow.
---

# Deploy Overview

Spry deployment is target-driven. You choose a runtime in `spry.config.dart`, then let `spry build` emit the correct output shape for that platform.

## The deployment split

- [Configuration](/config) explains every field in `defineSpryConfig(...)`
- this section explains how each deployment target behaves

Keep those concerns separate. Config defines intent. Deploy pages explain the platform consequences.

## Common flow

1. Pick `target` in `spry.config.dart`.
2. Run `dart run spry build`.
3. Deploy the generated output for that target.

## Targets

- [Dart VM](/deploy/dart)
- [Node.js](/deploy/node)
- [Bun](/deploy/bun)
- [Cloudflare Workers](/deploy/cloudflare)
- [Vercel](/deploy/vercel)

## Rule of thumb

Keep route code runtime-agnostic. Push runtime choice and output shaping into config, then use the target-specific deployment page only for the last mile.
