---
title: Guide → OpenAPI
description: Generate an OpenAPI 3.1 document from Spry routes, route-level metadata, and shared components.
---

# OpenAPI

Spry can generate an OpenAPI 3.1 document as part of the normal build
pipeline.

The mental model is:

- filesystem routes still define `paths`
- `spry.config.dart` defines document-level config
- route files can add operation metadata with a top-level `openapi`
- route files can also contribute shared `globalComponents`

## Imports

Use the normal config library for build settings and the OpenAPI library for
document objects:

```dart
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';
```

All OpenAPI builders are exported from `package:spry/openapi.dart`.

## Start with `spry.config.dart`

Enable OpenAPI generation in `defineSpryConfig(...)`:

<<< ../snippets/reference/openapi/spry.config.dart

Key points:

- `OpenAPIConfig.document` is the document seed.
- Spry still generates `paths` from the route tree.
- `OpenAPIOutput.route('openapi.json')` writes the final document into
  `public/`.
- `OpenAPIOutput.local(...)` can write to any other project-relative path.

## Route-level metadata

Each route file can expose a top-level `openapi` value:

<<< ../snippets/reference/openapi/routes.index.dart

That metadata becomes the operation object for the route.

Spry resolves `openapi` through the analyzer, so you can move reusable parts
into shared files, re-export them through your own barrels, and reference them
from route files.

## Shared route-level components

Use `globalComponents` when a route needs to contribute shared components to
the final document:

<<< ../snippets/reference/openapi/routes.users_id.dart

Those values are lifted into document-level `components` during generation.
They are not emitted as operation-local fields.

## Method expansion

Spry maps route files to OpenAPI operations using the same route model as the
runtime:

- `routes/index.dart` expands to `get`, `post`, `put`, `patch`, `delete`, and
  `options`
- explicit method files such as `routes/index.get.dart` override the expanded
  method for the same path
- `HEAD` is only emitted when a route explicitly defines `.head.dart`
- runtime `HEAD -> GET` fallback is not mirrored into OpenAPI

## Components merge strategy

Spry merges document-level `components` with lifted route-level
`globalComponents`.

Two merge modes are available:

- `OpenAPIComponentsMergeStrategy.strict`
  identical values are deduplicated; conflicting values fail the build
- `OpenAPIComponentsMergeStrategy.deepMerge`
  nested map-shaped values are merged recursively; conflicting leaf values still
  fail the build

Conflict errors include the component key and the contributing sources, so you
can see whether a conflict came from `openapi.document.components` or from a
specific route file.

## Webhooks

`OpenAPIDocumentConfig.webhooks` lets you declare root-level webhook path items
directly from config:

```dart
OpenAPIDocumentConfig(
  info: OpenAPIInfo(title: 'Spry API', version: '1.0.0'),
  webhooks: {
    'userCreated': OpenAPIPathItem(
      post: OpenAPIOperation(
        responses: {
          '202': OpenAPIRef.inline(
            OpenAPIResponse(description: 'Accepted'),
          ),
        },
      ),
    ),
  },
)
```

Webhook declarations are document-level config. They are not derived from
filesystem routes.

## Full example

For a runnable project, see the standalone example:

- [`example/openapi/README.md`](https://github.com/medz/spry/blob/main/example/openapi/README.md)
- [`example/openapi/spry.config.dart`](https://github.com/medz/spry/blob/main/example/openapi/spry.config.dart)

## API reference

The generated API docs for the public OpenAPI builders live on pub.dev:

- [Spry API reference](https://pub.dev/documentation/spry/latest/openapi/)
