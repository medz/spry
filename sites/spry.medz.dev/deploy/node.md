---
title: Deploy → Node.js
description: Target Node.js when your hosting environment is already centered on the Node runtime.
---

# Node.js

`BuildTarget.node` compiles your Spry application to JavaScript and wraps it in a CommonJS entry suitable for Node.js.

## Config

<<< ../../../example/node/spry.config.dart

## Build output

```text
.spry/
  src/
    main.dart           ← compile input
  node/
    index.cjs           ← CJS entry point
    runtime/
      main.js           ← compiled Dart-to-JS output
```

`index.cjs` is a thin bootstrap that sets up the global environment and loads `runtime/main.js`.

## Build and run

```bash
dart run spry build
node .spry/node/index.cjs
```

Or with Bun as a Node-compatible runtime:

```bash
bun .spry/node/index.cjs
```

## Production deployment

For a typical server deployment, copy the `.spry/node/` directory and your `public/` assets to the server, then run:

```bash
node index.cjs
```

You do not need the `routes/` source tree or the Dart SDK in production — only the compiled output.

## Good fit

- Existing Node-based hosting (VPS, Railway, Render, Fly.io)
- Environments where Node is the standard runtime contract
- Teams that want Dart route code but Node.js in production
