---
title: Deploy → Netlify
description: Use the Netlify target when you want Spry to emit a Netlify Functions workspace with the bootstrap files required by the host.
---

# Netlify

Spry's Netlify target emits a Functions-oriented workspace under `.spry/netlify/`.
That workspace includes the Netlify bootstrap files, the compiled runtime output, and a static `public/` directory for assets.

## Example config

<<< ../../../example/netlify/spry.config.dart

## Good fit

- Netlify-hosted server deployments
- projects that want Functions-style deployment instead of Edge middleware
- teams that want Spry to own the wrapper files for local dev and deploy output

## Practical note

This target is aimed at Netlify Functions, not Netlify Edge Functions.
Spry generates a `netlify.toml` rewrite so route requests fall through to the function while static files can still live in `public/`.
