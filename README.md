# Spry

[![Test](https://github.com/medz/spry/actions/workflows/test.yml/badge.svg)](https://github.com/medz/spry/actions/workflows/test.yml)
[![Pub Version](https://img.shields.io/pub/v/spry.svg)](https://pub.dev/packages/spry)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/medz/spry/blob/main/LICENSE)
[![X (twitter)](https://img.shields.io/badge/twitter-%40shiweidu-blue.svg)](https://twitter.com/shiweidu)
[![Documentation](https://img.shields.io/badge/docs-spry.medz.dev-brightgreen.svg)](https://spry.medz.dev/)
[![Netlify Status](https://api.netlify.com/api/v1/badges/186bd6a9-4783-4e3a-ad88-42259d67c8a5/deploy-status)](https://app.netlify.com/projects/dart-spry/deploys)

File-routing Dart server framework for teams that want one codebase across Dart VM, Node.js, Bun, Deno, Cloudflare Workers, Vercel, and Netlify.

Spry is built for a specific job:

- write server routes as files, not imperative registration code
- keep generated runtime output explicit and inspectable
- build the same project for multiple runtime targets
- generate OpenAPI documents and typed clients from the same source tree

If you want a Dart server framework that stays close to the filesystem, keeps deployment flexible, and does not hide the runtime behind a giant DSL, Spry is the fit.

## Why Spry

- `File routing first`: `routes/`, `middleware/`, `_middleware.dart`, and `_error.dart` define the server shape directly from the project tree.
- `Cross-runtime by design`: target Dart VM, native snapshots, Node.js, Bun, Deno, Cloudflare Workers, Vercel, and Netlify without rewriting route code.
- `Inspectable generated output`: Spry emits concrete runtime files instead of burying behavior inside a black box.
- `OpenAPI and client generation`: keep API contracts, docs, and first-party typed clients aligned with the same route tree.

## Start Here

- `Quick start`: install Spry, add `routes/`, add `spry.config.dart`, run `dart run spry serve`
- `Routing guide`: learn params, wildcards, scoped middleware, and error boundaries
- `Deploy guide`: see how the same project targets Dart, Node, Bun, Deno, Cloudflare, Vercel, and Netlify
- `Client and OpenAPI`: generate API docs and typed clients from the same app model

## Quick Start

Install the package:

```bash
dart pub add spry
```

Create a minimal project structure:

```text
.
├─ routes/
│  └─ index.dart
└─ spry.config.dart
```

`spry.config.dart`

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    host: '127.0.0.1',
    port: 4000,
    target: BuildTarget.vm,
  );
}
```

`routes/index.dart`

```dart
import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'message': 'hello from spry',
    'runtime': event.context.runtime.name,
    'path': event.url.path,
  });
}
```

Start the dev server:

```bash
dart run spry serve
```

## Core Ideas

- `routes/` defines request handlers with file routing
- `middleware/` and `_middleware.dart` shape cross-cutting request behavior
- `_error.dart` provides scoped error handling
- `defineHandler(...)` adds handler-local middleware and error handling
- `public/` serves static assets directly
- `spry.config.dart` selects the runtime target and build behavior

## What You Ship

With Spry, the authoring model stays small:

- handlers return `Response` values directly
- route structure comes from folders and filenames
- scoped middleware and errors stay near the routes they affect
- config decides the runtime target instead of per-route branching

What Spry generates:

- a concrete app definition you can inspect
- runtime entry files for the selected target
- target-specific wrappers for platforms like Cloudflare Workers or Vercel

## OpenAPI

Spry can generate an `openapi.json` document as part of the normal build
pipeline.

Use `package:spry/config.dart` for the build-side config and
`package:spry/openapi.dart` for the document objects:

```dart
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';

void main() {
  defineSpryConfig(
    openapi: OpenAPIConfig(
      document: OpenAPIDocumentConfig(
        info: OpenAPIInfo(title: 'Spry API', version: '1.0.0'),
      ),
      output: OpenAPIOutput.route('openapi.json'),
    ),
  );
}
```

Route files can expose top-level `openapi` metadata:

```dart
import 'package:spry/openapi.dart';

final openapi = OpenAPI(
  summary: 'List users',
  tags: ['users'],
);
```

Key rules:

- `OpenAPIConfig.document.components` defines document-level components.
- Route-level `OpenAPI(..., globalComponents: ...)` is lifted into document
  `components` during generation.
- A route without a method suffix expands to `GET`, `POST`, `PUT`, `PATCH`,
  `DELETE`, and `OPTIONS` in OpenAPI.
- `HEAD` is only emitted when a route explicitly defines `.head.dart`.
- `OpenAPIOutput.route('openapi.json')` writes the file into `public/`, so it is
  served like any other static asset.

## Runtime Targets

Spry can emit output for:

| Target | Runtime | Deploy Docs |
|---|---|---|
| `vm` | Dart VM | [Dart VM](https://spry.medz.dev/deploy/dart) |
| `exe` | Native executable | [Native executable](https://spry.medz.dev/deploy/dart#native-executable) |
| `aot` | AOT snapshot | [AOT snapshot](https://spry.medz.dev/deploy/dart#aot-snapshot) |
| `jit` | JIT snapshot | [JIT snapshot](https://spry.medz.dev/deploy/dart#jit-snapshot) |
| `kernel` | Kernel snapshot | [Kernel snapshot](https://spry.medz.dev/deploy/dart#kernel-snapshot) |
| `node` | Node.js | [Node.js](https://spry.medz.dev/deploy/node) |
| `bun` | Bun | [Bun](https://spry.medz.dev/deploy/bun) |
| `deno` | Deno | [Deno](https://spry.medz.dev/deploy/deno) |
| `cloudflare` | Cloudflare Workers | [Cloudflare Workers](https://spry.medz.dev/deploy/cloudflare) |
| `vercel` | Vercel | [Vercel](https://spry.medz.dev/deploy/vercel) |
| `netlify` | Netlify Functions | [Netlify Functions](https://spry.medz.dev/deploy/netlify) |

## WebSockets

Spry exposes websocket upgrades from the request event without introducing a
second routing system.

```dart
import 'package:spry/spry.dart';
import 'package:spry/websocket.dart';

Response handler(Event event) {
  if (!event.ws.isSupported || !event.ws.isUpgradeRequest) {
    return Response('plain http fallback');
  }

  return event.ws.upgrade((ws) async {
    ws.sendText('connected');

    await for (final message in ws.events) {
      switch (message) {
        case TextDataReceived(text: final text):
          ws.sendText('echo:$text');
        case BinaryDataReceived():
        case CloseReceived():
          break;
      }
    }
  }, protocol: 'chat');
}
```

Current websocket support follows the underlying `osrv` runtime surface:

- supported: Dart VM, Node.js, Bun, Deno, Cloudflare Workers
- unsupported: Vercel, current Netlify Functions runtime

## Documentation

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/medz/spry)

Read the documentation at [spry.medz.dev](https://spry.medz.dev/).

Start here:

- [Getting Started](https://spry.medz.dev/getting-started)
- [File Routing](https://spry.medz.dev/guide/routing)
- [Configuration](https://spry.medz.dev/config)
- [Deploy Overview](https://spry.medz.dev/deploy/)

## License

[MIT](https://github.com/medz/spry/blob/main/LICENSE)

## Sponsors

Spry framework is an [MIT licensed](https://github.com/medz/spry/blob/main/LICENSE) open source project with its ongoing development made possible entirely by the support of these awesome backers. If you'd like to join them, please consider [sponsoring Seven(@medz)](https://github.com/sponsors/medz) development.

<p align="center">
  <a target="_blank" href="https://github.com/sponsors/medz#:~:text=Featured-,sponsors,-Current%20sponsors">
    <img alt="sponsors" src="https://cdn.jsdelivr.net/gh/medz/public/sponsors.tiers.svg">
  </a>
</p>

## Contributing

Thank you to all the people who already contributed to Spry!

[![Contributors](https://contrib.rocks/image?repo=medz/spry)](https://github.com/medz/spry/graphs/contributors)
