---
title: Deploy → Deno
description: Use the Deno target when you want a JavaScript-hosted listener runtime backed by Deno.serve.
---

# Deno

`BuildTarget.deno` compiles your Spry application to a JavaScript file that runs under `deno run`.

## Config

<<< ../../../example/deno/spry.config.dart

## Build output

```text
.spry/
  src/
    main.dart       ← compile input
  deno/
    index.js        ← compiled output, run with deno
```

## Build and run

```bash
dart run spry build
deno run --allow-net .spry/deno/index.js
```

Grant additional permissions as needed by your app:

```bash
deno run --allow-net --allow-read --allow-env .spry/deno/index.js
```

## Deno Deploy

To deploy to [Deno Deploy](https://deno.com/deploy), push `index.js` to a repository and point your project entrypoint at it, or use the `deployctl` CLI:

```bash
deployctl deploy --project=my-app .spry/deno/index.js
```

## Good fit

- Teams already deploying on Deno
- Self-hosted deployments where `deno run` is the runtime contract
- Deno Deploy for a zero-config edge option
