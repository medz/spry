---
title: Deploy → Node.js
description: Target Node.js when your hosting environment is already centered on the Node runtime.
---

# Node.js

Use `BuildTarget.node` when the deployment environment is already Node-oriented or your platform expects a Node runtime.

## Example config

<<< ../../../example/node/spry.config.dart

## Good fit

- existing Node-based hosting
- environments where Node is the standard runtime contract
- teams that want Spry route code in Dart but production hosting in Node

## Practical note

Keep your route tree in Dart. Only the emitted runtime target changes. That separation is the value of the Node target.
