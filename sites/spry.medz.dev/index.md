---
layout: home
title: Spry
description: Next-generation Dart server framework for building modern server apps and deploying them across multiple runtimes.
titleTemplate: false
hero:
  name: Spry
  text: Ship Cross-Runtime Dart Servers
  tagline: Next-generation Dart server framework. Build modern servers and deploy them to the runtime you prefer.
  actions:
    - theme: brand
      text: Quick Start
      link: /getting-started
    - theme: alt
      text: Explore File Routing
      link: /guide/routing
    - theme: alt
      text: GitHub
      link: https://github.com/medz/spry
features:
  - title: File routing first
    details: Start with folders and route files. Spry scans your tree and generates a concrete app definition you can inspect.
  - title: One app, many runtimes
    details: Build the same project for Dart VM, Node, Bun, Cloudflare Workers, or Vercel with explicit targets.
  - title: Small, sharp runtime model
    details: Handlers, middleware, scoped error boundaries, public assets, and lifecycle hooks without a giant abstraction stack.
---

<div class="spry-band">
  <div class="spry-band__card">
    <div class="spry-band__eyebrow">Start local</div>
    <h3>Develop with <code>spry serve</code></h3>
    <p>Stay inside a normal Dart project, add a <code>routes/</code> tree, and let Spry build and serve the generated app during development.</p>
  </div>
  <div class="spry-band__card">
    <div class="spry-band__eyebrow">Deploy wide</div>
    <h3>Target the runtime you need</h3>
    <p>Use <code>defineSpryConfig(...)</code> to control host, port, output, reload behavior, and build target without changing your route code.</p>
  </div>
  <div class="spry-band__card">
    <div class="spry-band__eyebrow">Stay inspectable</div>
    <h3>Generated output is part of the story</h3>
    <p>Spry does not hide its runtime entry. The scanner emits a real app and a real main file so the build stays understandable.</p>
  </div>
</div>

## Build from the file tree

Spry is organized around a runtime pipeline, not around imperative route registration. The folder tree is the contract. Route files define handlers. `_middleware.dart` and `_error.dart` shape behavior by scope. `spry.config.dart` decides how the generated output should run.

::: code-group
```text [project tree]
.
├─ routes/
│  ├─ index.dart
│  ├─ about.get.dart
│  ├─ users/[id].dart
│  ├─ [...slug].dart
│  ├─ _middleware.dart
│  └─ _error.dart
├─ middleware/
│  └─ 01_logger.dart
├─ public/
│  └─ hello.txt
├─ hooks.dart
└─ spry.config.dart
```

```dart [routes/index.dart]
import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'message': 'hello from spry',
    'runtime': event.context.runtime.name,
    'path': event.url.path,
  });
}
```

```dart [spry.config.dart]
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    host: '127.0.0.1',
    port: 4000,
    target: BuildTarget.vm,
  );
}
```
:::

## A sharper way to structure Dart servers

<div class="spry-story">
  <div class="spry-story__card">
    <div class="spry-story__meta">Framework model</div>
    <h2>Generated app, direct runtime control</h2>
    <p>Spry keeps the authoring model simple: folders define routes, scoped files shape behavior, and runtime choice stays in config. The result is less ceremony than a traditional server stack without turning the framework into a black box.</p>
    <div class="spry-chip-row">
      <span class="spry-chip"><code>routes/</code> scanner</span>
      <span class="spry-chip">Scoped middleware</span>
      <span class="spry-chip">Scoped error boundaries</span>
      <span class="spry-chip">Public asset serving</span>
      <span class="spry-chip">Lifecycle hooks</span>
    </div>
  </div>
  <div class="spry-story__card">
    <div class="spry-story__meta">What you write</div>
    <ul>
      <li>Handlers return <code>Response</code> values directly.</li>
      <li>Middleware composes with <code>Next</code> instead of global mutation.</li>
      <li>Params and locals live on a request-scoped <code>Event</code> object.</li>
      <li>Targets are selected in config rather than per-route conditionals.</li>
    </ul>
    <div class="spry-story__meta" style="margin-top: 20px;">What Spry generates</div>
    <ul>
      <li>A concrete <code>Spry(...)</code> app with route and middleware maps.</li>
      <li>A runtime-specific <code>main.dart</code> entrypoint.</li>
      <li>Target extras such as Vercel or Cloudflare wrappers when needed.</li>
    </ul>
  </div>
</div>

## Read the docs in the same order you build

1. Start with [Getting Started](/getting-started) to get a minimal project running.
2. Read [Project Structure](/guide/app), [File Routing](/guide/routing), and [Middleware and Errors](/guide/handler) to learn the actual authoring model.
3. Include [Client](/guide/client) when you want a generated first-party client.
4. Use [OpenAPI](/guide/openapi) when you want stronger request and response contracts, or a generated OpenAPI document.
5. Configure [Assets](/guide/assets), [Lifecycle](/guide/lifecycle), [Request Context](/guide/event), and [WebSockets](/guide/websocket) once the basics are in place.
6. Use [Configuration](/config), then move to [Deploy Overview](/deploy/) when you are ready to run the same code outside Dart VM.

<div class="spry-cta">
  <h2 style="margin-top: 0;">Spry is at its best when the folder layout stays boring and the runtime matrix stays flexible.</h2>
  <p>That is the design center for the docs. Minimal files, explicit output, and deployment targets that do not force a rewrite.</p>
  <div class="spry-cta__actions">
    <a class="VPButton brand medium" href="/getting-started">Open the quick start</a>
    <a class="VPButton alt medium" href="/deploy/">See deploy targets</a>
  </div>
</div>

[![Netlify Status](https://api.netlify.com/api/v1/badges/186bd6a9-4783-4e3a-ad88-42259d67c8a5/deploy-status)](https://app.netlify.com/projects/dart-spry/deploys)
