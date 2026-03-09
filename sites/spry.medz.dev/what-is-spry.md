---
title: What is Spry?
description: Spry is a file-routing-first Dart framework for building server applications that can cross runtime boundaries.
---

# What is Spry?

Spry is a lightweight Dart web framework built around a simple idea: the folder tree should describe the server, and the framework should generate the runtime entrypoint needed to run it.

## What makes it different

Spry is not trying to be a giant application container. It is trying to be a sharp server layer with:

- file-based routing
- generated app output you can inspect
- explicit middleware and scoped error boundaries
- static asset support
- runtime portability across Dart and selected JavaScript targets

## The authoring model

You write a project like this:

```text
routes/
middleware/
public/
hooks.dart
spry.config.dart
```

Spry scans that structure and builds a concrete app definition from it.

## The deployment model

Spry lets you target:

- Dart VM
- Node
- Bun
- Cloudflare Workers
- Vercel
