---
layout: home
title: Spry
description: File-routing Dart server framework for teams that want one codebase across Dart VM, Node.js, Bun, Deno, Cloudflare Workers, Vercel, and Netlify.
titleTemplate: false
hero:
  name: Spry
  text: Build Dart APIs Once. Deploy Anywhere.
  tagline: File-routing Dart server framework with inspectable generated output, OpenAPI generation, and first-party typed clients.
  actions:
    - theme: brand
      text: Quick Start
      link: /getting-started
    - theme: alt
      text: Runtime Targets
      link: /deploy/
    - theme: alt
      text: GitHub
      link: https://github.com/medz/spry
features:
  - title: File routing without framework magic
    details: Start with folders and route files. Spry scans your tree, builds a concrete app definition, and keeps the runtime output inspectable.
  - title: One Dart codebase across runtimes
    details: Build the same project for Dart VM, Node.js, Bun, Deno, Cloudflare Workers, Vercel, and Netlify with explicit targets.
  - title: Contracts that stay in sync
    details: Generate OpenAPI documents and first-party typed clients from the same route tree instead of hand-maintaining parallel API layers.
---

<div class="spry-band">
  <div class="spry-band__card">
    <div class="spry-band__eyebrow">Author fast</div>
    <h3>Use the filesystem as the contract</h3>
    <p>Model routes, scoped middleware, and scoped errors with normal files instead of central route registries and framework ceremony.</p>
  </div>
  <div class="spry-band__card">
    <div class="spry-band__eyebrow">Deploy wide</div>
    <h3>Change targets, not route code</h3>
    <p>Use <code>defineSpryConfig(...)</code> to choose the runtime target and build output without rewriting handlers for each platform.</p>
  </div>
  <div class="spry-band__card">
    <div class="spry-band__eyebrow">Stay in control</div>
    <h3>Generated output is visible by design</h3>
    <p>Spry emits a real app and real runtime entry files so the build pipeline stays understandable during debugging, review, and deployment.</p>
  </div>
</div>

## Why teams look at Spry

- They want file routing in Dart, but do not want the framework to become a black box.
- They want one API project that can ship to Dart VM locally and edge or JavaScript runtimes later.
- They want OpenAPI and typed clients generated from the real app model instead of maintained by hand.
- They want deployment flexibility without moving to a different server abstraction every time infrastructure changes.

## Build from the file tree

Spry is organized around a runtime pipeline, not around imperative route registration. The folder tree is the contract. Route files define handlers. `defineHandler(...)` keeps one-off behavior local to one route. `_middleware.dart` and `_error.dart` shape broader behavior by scope. `spry.config.dart` decides how the generated output should run.

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

## What you keep simple

<div class="spry-story">
  <div class="spry-story__card">
    <div class="spry-story__meta">Framework model</div>
    <h2>Normal Dart handlers, local composition, direct runtime control</h2>
    <p>Spry keeps the authoring model small: folders define routes, scoped files shape behavior, and runtime choice stays in config. The result is less ceremony than a traditional server stack without hiding how the app runs.</p>
    <div class="spry-chip-row">
      <span class="spry-chip"><code>routes/</code> scanner</span>
      <span class="spry-chip">Scoped middleware</span>
      <span class="spry-chip">Scoped error boundaries</span>
      <span class="spry-chip">Public asset serving</span>
      <span class="spry-chip">Lifecycle hooks</span>
    </div>
  </div>
  <div class="spry-story__card">
    <div class="spry-story__meta">Authoring model</div>
    <ul>
      <li>Handlers return <code>Response</code> values directly.</li>
      <li><code>defineHandler(...)</code> can wrap one route without introducing more files.</li>
      <li>Middleware composes with <code>Next</code> instead of global mutation.</li>
      <li>Params and locals live on a request-scoped <code>Event</code> object.</li>
      <li>Targets are selected in config rather than per-route conditionals.</li>
    </ul>
    <div class="spry-story__meta" style="margin-top: 20px;">Build output</div>
    <ul>
      <li>A concrete <code>Spry(...)</code> app with route and middleware maps.</li>
      <li>A runtime-specific <code>main.dart</code> entrypoint.</li>
      <li>Target extras such as Vercel or Cloudflare wrappers when needed.</li>
    </ul>
  </div>
</div>

## Good fit for

- API projects that want file routing and explicit generated output
- teams evaluating Dart for backend work but needing deployment flexibility
- apps that benefit from generated OpenAPI and typed clients
- server projects that may start on Dart VM and later move to Bun, Deno, Cloudflare, or Node.js

## Less ideal for

- teams that want a large batteries-included application platform
- projects that need ORM, auth, jobs, and admin tooling bundled into the framework
- codebases that prefer imperative route registration over filesystem structure

## Read the docs in the same order you build

1. Start with [Getting Started](/getting-started) to get a minimal project running.
2. Read [Project Structure](/guide/app), [File Routing](/guide/routing), and [Middleware and Errors](/guide/handler) to learn the actual authoring model.
3. Include [Client](/guide/client) when you want a generated first-party client.
4. Use [OpenAPI](/guide/openapi) when you want stronger request and response contracts, or a generated OpenAPI document.
5. Configure [Assets](/guide/assets), [Lifecycle](/guide/lifecycle), [Request Context](/guide/event), and [WebSockets](/guide/websocket) once the basics are in place.
6. Use [Configuration](/config), then move to [Deploy Overview](/deploy/) when you are ready to run the same code outside Dart VM.

<div class="spry-cta">
  <h2 style="margin-top: 0;">Spry is strongest when you want boring folders, explicit output, and deployment optionality.</h2>
  <p>Start with the quick start if you want to run a real project today, or jump to deploy docs if you are evaluating runtime targets first.</p>
  <div class="spry-cta__actions">
    <a class="VPButton brand medium" href="/getting-started">Open the quick start</a>
    <a class="VPButton alt medium" href="/guide/client">See client generation</a>
  </div>
</div>

[![Netlify Status](https://api.netlify.com/api/v1/badges/186bd6a9-4783-4e3a-ad88-42259d67c8a5/deploy-status)](https://app.netlify.com/projects/dart-spry/deploys)
