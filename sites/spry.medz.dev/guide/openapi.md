---
title: Guide → OpenAPI
description: Generate an OpenAPI 3.1 document from Spry routes, route-level metadata, and shared components.
---

# OpenAPI

Spry can generate an OpenAPI 3.1 document as part of `spry build` and
`spry serve`.

This guide covers the full authoring model:

- document-level config in `spry.config.dart`
- route-level operation metadata with a top-level `openapi`
- shared reusable spec values resolved through the analyzer
- document `components` and route-level `globalComponents`
- common object builders for schemas, parameters, request/response bodies,
  security, callbacks, and webhooks
- generation rules and merge behavior

## Mental model

Spry keeps route structure and OpenAPI structure separate:

- filesystem routing is still the source of truth for `paths`
- `OpenAPIConfig.document` seeds the root document
- each route file can contribute operation metadata with `final openapi = ...`
- route files can also contribute shared components with `globalComponents`
- the final `openapi.json` is generated from both the route tree and the
  OpenAPI metadata tree

Think of `spry.config.dart` as the document root and route files as operation
patches.

## Imports

Use the normal config library for build settings and the OpenAPI library for
document objects:

```dart
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';
```

Everything in the typed OpenAPI authoring surface is exported from
`package:spry/openapi.dart`.

## Configure document generation

Enable OpenAPI generation in `defineSpryConfig(...)`:

<<< ../snippets/reference/openapi/spry.config.dart

The important pieces are:

- `OpenAPIConfig.document`
  document-level metadata such as `info`, `components`, `servers`, `tags`,
  `security`, `webhooks`, and `externalDocs`
- `OpenAPIOutput.route('openapi.json')`
  writes the generated document into `public/`
- `OpenAPIOutput.local(...)`
  writes to another project-relative path
- `componentsMergeStrategy`
  controls how document `components` and route `globalComponents` are merged

`paths` are never configured manually here. Spry derives them from `routes/`.

## Add route-level metadata

Each route file can expose a top-level `openapi` value:

<<< ../snippets/reference/openapi/routes.index.dart

That value becomes the operation metadata for the route. The route `handler`
still controls runtime behavior; `openapi` only affects the generated document.

Common fields on `OpenAPI(...)` / `OpenAPIOperation(...)` include:

- `tags`
- `summary`
- `description`
- `externalDocs`
- `operationId`
- `parameters`
- `requestBody`
- `responses`
- `callbacks`
- `deprecated`
- `security`
- `servers`
- `extensions`

## Reuse shared spec values

Spry resolves route-level `openapi` through the analyzer, not by evaluating raw
JSON maps. That means reuse is not limited to the top-level `openapi` object.
You can extract any nested spec value into shared Dart files, including:

- `parameters`
- `requestBody`
- `responses`
- `security`
- callback path items
- `globalComponents` buckets such as `schemas` and `securitySchemes`
- child fields inside those objects, as long as the shared value ultimately
  resolves to Spry's typed OpenAPI builders

In other words, users can build a local spec architecture and compose route
metadata from small reusable values instead of writing everything inline.

Example shared values:

<<< ../snippets/reference/openapi/shared.dart

Then reuse them in routes or config:

```dart
import 'package:spry/openapi.dart';
import '../shared/openapi_parts.dart' as shared;

final openapi = OpenAPI(
  summary: 'Get one user',
  parameters: [
    OpenAPIRef.inline(
      OpenAPIParameter.path(
        'id',
        schema: OpenAPISchema.ref('#/components/schemas/UserId'),
      ),
    ),
  ],
  responses: {
    '200': shared.userResponse,
  },
  security: [shared.bearerSecurity],
);
```

Spry allows:

- direct `OpenAPI(...)` values
- references to top-level reusable spec values
- nested reusable values inside other reusable values
- nested child and sub-child properties composed from reusable spec values
- user-defined barrels and re-exports, as long as the final resolved types come
  from Spry's OpenAPI library

Spry intentionally rejects:

- raw top-level `openapi = {...}` maps
- local fake types named `OpenAPI`, `OpenAPIComponents`, and similar
- values that do not resolve back to Spry's actual OpenAPI builders

## Define shared components

Document-level components live in `OpenAPIConfig.document.components`:

```dart
OpenAPIDocumentConfig(
  info: OpenAPIInfo(title: 'Spry API', version: '1.0.0'),
  components: OpenAPIComponents(
    schemas: {
      'UserId': OpenAPISchema.string(),
      'User': OpenAPISchema.object({
        'id': OpenAPISchema.ref('#/components/schemas/UserId'),
        'name': OpenAPISchema.string(),
      }),
    },
    securitySchemes: {
      'bearerAuth': OpenAPISecurityScheme.http(scheme: 'bearer'),
    },
  ),
)
```

Route-level shared components use `globalComponents`:

<<< ../snippets/reference/openapi/routes.users_id.dart

These are lifted into the root `components` object during generation. They do
not stay nested inside the operation.

`OpenAPIComponents(...)` currently supports:

- `schemas`
- `responses`
- `parameters`
- `examples`
- `requestBodies`
- `headers`
- `securitySchemes`
- `links`
- `callbacks`
- `pathItems`
- `extensions`

## Use refs and inline values

Spry follows OpenAPI's usual inline-or-ref pattern with `OpenAPIRef<T>`:

```dart
responses: {
  '200': OpenAPIRef.inline(
    OpenAPIResponse(description: 'OK'),
  ),
  '404': OpenAPIRef.ref('#/components/responses/NotFound'),
}
```

Path items are the main exception. `OpenAPIPathItem` supports `\$ref` directly:

```dart
OpenAPIPathItem(
  $ref: '#/components/pathItems/UserCreatedWebhook',
)
```

## Build schemas

`OpenAPISchema` is the central schema builder. It supports both normal schema
objects and boolean schemas.

Common factories:

- `OpenAPISchema.string()`
- `OpenAPISchema.integer()`
- `OpenAPISchema.number()`
- `OpenAPISchema.boolean()`
- `OpenAPISchema.null_()`
- `OpenAPISchema.object({...})`
- `OpenAPISchema.array(...)`
- `OpenAPISchema.ref(...)`
- `OpenAPISchema.nullable(...)`
- `OpenAPISchema.oneOf(...)`
- `OpenAPISchema.anyOf(...)`
- `OpenAPISchema.allOf(...)`
- `OpenAPISchema.additional({...})`
- `OpenAPISchema.anything()`
- `OpenAPISchema.nothing()`

Example:

```dart
final userSchema = OpenAPISchema.object(
  {
    'id': OpenAPISchema.string(),
    'name': OpenAPISchema.string(),
    'nickname': OpenAPISchema.nullable(OpenAPISchema.string()),
  },
  requiredProperties: ['id', 'name'],
);
```

## Parameters, request bodies, and responses

Route metadata usually centers around three objects:

- `OpenAPIParameter`
- `OpenAPIRequestBody`
- `OpenAPIResponse`

Path/query/header/cookie parameters are built with dedicated factories:

```dart
OpenAPIParameter.query(
  'limit',
  schema: OpenAPISchema.integer(minimum: 1),
  description: 'Page size.',
)
```

Parameters support either `schema` or `content`, but not both. When using
`content`, provide exactly one media type entry.

Request body example:

```dart
OpenAPIRequestBody(
  required: true,
  content: {
    'application/json': OpenAPIMediaType(
      schema: OpenAPISchema.object({
        'name': OpenAPISchema.string(),
      }),
    ),
  },
)
```

Response example:

```dart
OpenAPIResponse(
  description: 'Created user',
  headers: {
    'Location': OpenAPIRef.inline(
      OpenAPIHeader(
        schema: OpenAPISchema.string(),
        description: 'Canonical resource URL.',
      ),
    ),
  },
  content: {
    'application/json': OpenAPIMediaType(
      schema: OpenAPISchema.ref('#/components/schemas/User'),
    ),
  },
)
```

## Security and OAuth

Security requirements can be attached at the document or operation level:

```dart
OpenAPISecurityRequirement({
  'bearerAuth': [],
})
```

Security schemes belong in `components.securitySchemes`:

```dart
OpenAPISecurityScheme.http(
  scheme: 'bearer',
)
```

Other supported schemes:

- `OpenAPISecurityScheme.apiKey(...)`
- `OpenAPISecurityScheme.oauth2(...)`
- `OpenAPISecurityScheme.openIdConnect(...)`
- `OpenAPISecurityScheme.mutualTLS(...)`

OAuth flows use explicit factories:

```dart
OpenAPISecurityScheme.oauth2(
  flows: OpenAPIOAuthFlows(
    authorizationCode: OpenAPIOAuthFlow.authorizationCode(
      authorizationUrl: 'https://example.com/oauth/authorize',
      tokenUrl: 'https://example.com/oauth/token',
      scopes: {
        'users:read': 'Read users',
      },
    ),
  ),
)
```

## Callbacks and webhooks

Callbacks are operation-level reusable path items:

```dart
OpenAPI(
  callbacks: {
    'userUpdated': OpenAPIRef.inline({
      '{$request.body#/callbackUrl}': OpenAPIPathItem(
        post: OpenAPIOperation(
          responses: {
            '202': OpenAPIRef.inline(
              OpenAPIResponse(description: 'Accepted'),
            ),
          },
        ),
      ),
    }),
  },
)
```

Webhooks are root-level path items declared in config:

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

Callbacks are attached to operations. Webhooks live at the root document level.

## Generation rules

Spry maps route files to operations using the filesystem routing model:

- `routes/index.dart` expands to `get`, `post`, `put`, `patch`, `delete`, and
  `options`
- explicit method files such as `routes/index.get.dart` override the expanded
  method for the same path
- `HEAD` is only emitted when a route explicitly defines `.head.dart`
- runtime `HEAD -> GET` fallback is not mirrored into OpenAPI
- route path params are converted to OpenAPI path syntax such as `/users/{id}`

## Components merge strategy

Spry merges document-level `components` with lifted route-level
`globalComponents`.

Available modes:

- `OpenAPIComponentsMergeStrategy.strict`
  same-name identical values are deduplicated; conflicting values fail the
  build
- `OpenAPIComponentsMergeStrategy.deepMerge`
  nested map-shaped values are merged recursively; conflicting leaf values
  still fail the build

Conflict errors include both the component key and the contributing sources, so
you can tell whether the conflict came from `openapi.document.components` or
from a specific route file.

## Output location

Two output modes are available:

- `OpenAPIOutput.route('openapi.json')`
  writes into `public/` so the file is served as a static asset
- `OpenAPIOutput.local('docs/openapi.json')`
  writes to another path under the project root

If you want a public `/openapi.json`, the normal pattern is
`OpenAPIOutput.route('openapi.json')`.

## Runnable example

For a complete runnable project, see the standalone example:

- [`example/openapi/README.md`](https://github.com/medz/spry/blob/main/example/openapi/README.md)
- [`example/openapi/spry.config.dart`](https://github.com/medz/spry/blob/main/example/openapi/spry.config.dart)
- [`example/openapi/routes/index.dart`](https://github.com/medz/spry/blob/main/example/openapi/routes/index.dart)
- [`example/openapi/routes/users/%5Bid%5D.dart`](https://github.com/medz/spry/blob/main/example/openapi/routes/users/%5Bid%5D.dart)

## API reference

For the full generated API docs:

- [OpenAPI library API reference](https://pub.dev/documentation/spry/latest/openapi/)
