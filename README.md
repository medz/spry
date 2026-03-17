# Spry

[![Test](https://github.com/medz/spry/actions/workflows/test.yml/badge.svg)](https://github.com/medz/spry/actions/workflows/test.yml)
[![Pub Version](https://img.shields.io/pub/v/spry.svg)](https://pub.dev/packages/spry)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/medz/spry/blob/main/LICENSE)
[![X (twitter)](https://img.shields.io/badge/twitter-%40shiweidu-blue.svg)](https://twitter.com/shiweidu)
[![Documentation](https://img.shields.io/badge/docs-spry.medz.dev-brightgreen.svg)](https://spry.medz.dev/)
[![Netlify Status](https://api.netlify.com/api/v1/badges/186bd6a9-4783-4e3a-ad88-42259d67c8a5/deploy-status)](https://app.netlify.com/projects/dart-spry/deploys)

Next-generation Dart server framework. Build modern servers and deploy them to the runtime you prefer.

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
    target: BuildTarget.dart,
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
- `public/` serves static assets directly
- `spry.config.dart` selects the runtime target and build behavior

## Runtime Targets

Spry can emit output for:

- Dart VM
- Node.js
- Bun
- Cloudflare Workers
- Vercel

## Documentation

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/medz/spry)

Read the v7 documentation at [spry.medz.dev](https://spry.medz.dev/).

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
