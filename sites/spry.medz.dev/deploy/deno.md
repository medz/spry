---
title: Deploy → Deno
description: Use the Deno target when you want a JavaScript-hosted listener runtime backed by Deno.serve.
---

# Deno

Use `BuildTarget.deno` when you want a JS-hosted listener runtime built around `Deno.serve(...)`.

## Example config

<<< ../../../example/deno/spry.config.dart

## Good fit

- teams already deploying server workloads on Deno
- self-hosted deployments where `deno run` is the runtime contract
- projects that want Spry route code in Dart but a Deno listener in production

## Practical note

`spry serve` starts Deno with network access for the generated listener entry. In production, make sure your deployment command grants the permissions your app actually needs, typically including `--allow-net`.
