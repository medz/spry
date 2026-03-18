---
title: Deploy → Vercel
description: Use the Vercel target when you want Spry to emit the extra wrapper files required by Vercel-hosted server execution.
---

# Vercel

Vercel is the most platform-shaped target in the list. Spry emits the extra wrapper files needed for it during build.

## Example config

<<< ../../../example/vercel/spry.config.dart

## Good fit

- Vercel-hosted server deployments
- environments where Vercel is the operational default
- teams that want platform-specific output without rewriting the route layer

## Practical note

This target is where the generated output matters most. Keep your app code generic and let Spry shape the final wrapper for the platform.
