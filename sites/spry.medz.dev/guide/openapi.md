---
title: Guide → OpenAPI
description: Generate an OpenAPI 3.1 document from Spry routes, route-level operation metadata, and shared components.
---

# OpenAPI

Spry generates an OpenAPI 3.1 document as part of `spry build` and `spry serve`.

The authoring model keeps route structure and API documentation in sync automatically: the filesystem is still the source of truth for `paths`, and each route file can declare its own operation metadata alongside the handler.

## Mental model

There are two authoring surfaces:

- **`spry.config.dart`** — seeds the root document: `info`, `servers`, `tags`, `security`, `webhooks`, `components`, and the output location
- **route files** — each route file can expose a top-level `openapi` value that becomes the operation metadata for that route

At build time, Spry merges them:

1. `openapi.document` seeds the root
2. Each route's `openapi` is placed under `paths`
3. Route-level `globalComponents` are lifted into the root `components`
4. The complete document is written to the configured output path

`paths` are never written by hand. Spry derives them from `routes/`.

## Imports

```dart
import 'package:spry/config.dart';   // OpenAPIConfig, OpenAPIOutput, etc.
import 'package:spry/openapi.dart';  // all OpenAPI object builders
```

All typed OpenAPI builders live in `package:spry/openapi.dart`.
Config types (`OpenAPIConfig`, `OpenAPIOutput`, `OpenAPIDocumentConfig`, `OpenAPIComponentsMergeStrategy`) are exported from `package:spry/config.dart`.

## Configure document generation

Enable OpenAPI generation in `spry.config.dart`:

<<< ../snippets/reference/openapi/spry.config.dart

The key pieces:

| Field | Description |
|---|---|
| `document` | Document-level metadata: `info`, `components`, `servers`, `tags`, `security`, `webhooks`, `externalDocs` |
| `output` | Where to write the file — `OpenAPIOutput.route(path)` puts it in `public/`; `OpenAPIOutput.local(path)` writes to any project-relative path |
| `componentsMergeStrategy` | How route-level `globalComponents` are merged with document components |

## Add route-level operation metadata

Each route file can declare a top-level `openapi` value:

<<< ../snippets/reference/openapi/routes.index.dart

The `openapi` variable becomes the operation metadata for that route. The `handler` controls runtime behavior; `openapi` only affects the generated document.

Supported fields on `OpenAPI(...)`:

| Field | Type | Description |
|---|---|---|
| `tags` | `List<String>` | Operation tags |
| `summary` | `String` | Short one-line description |
| `description` | `String` | Longer description, supports Markdown |
| `operationId` | `String` | Unique identifier for the operation |
| `parameters` | `Object` | List of `OpenAPIRef<OpenAPIParameter>` |
| `requestBody` | `Object` | `OpenAPIRef<OpenAPIRequestBody>` |
| `responses` | `Object` | Map of status code → `OpenAPIRef<OpenAPIResponse>` |
| `callbacks` | `Map<String, OpenAPIRef<OpenAPICallback>>` | Operation-level callbacks |
| `security` | `Object` | List of `OpenAPISecurityRequirement` |
| `servers` | `List<OpenAPIServer>` | Operation-level server overrides |
| `deprecated` | `bool` | Mark as deprecated |
| `externalDocs` | `OpenAPIExternalDocs` | External documentation link |
| `extensions` | `Map<String, dynamic>` | Vendor extensions (keys get `x-` prefix automatically) |
| `globalComponents` | `OpenAPIComponents` | Shared components to lift to document root |

### Auto-generated path parameters

For routes with path segments (e.g. `routes/users/[id].dart` → `/users/{id}`), Spry automatically injects a minimal parameter entry for every `{param}` that the developer has not already declared.

OAS 3.1 mandates that path parameters always carry `required: true` — a path parameter that is absent means the path itself does not match, so the concept of an optional path parameter does not exist in the specification. All auto-generated stubs therefore use `required: true` regardless of the roux route modifier.

The stub schema defaults to `{"type": "string"}`. If you want a richer definition — a specific schema, description, or style — declare the parameter explicitly and Spry will use your definition instead:

```dart
final openapi = OpenAPI(
  summary: 'Get user',
  parameters: [
    OpenAPIRef.inline(
      OpenAPIParameter.path(
        'id',
        schema: OpenAPISchema.ref('#/components/schemas/UserId'),
        description: 'Stable user identifier.',
      ),
    ),
  ],
  responses: {'200': shared.userResponse},
);
```

You can mix explicit and auto-generated params — only the ones you have not declared receive a stub.

### Default responses stub

All fields on `OpenAPI(...)` are optional. When `responses` is omitted, Spry automatically injects a minimal OAS 3.1–compliant stub:

```json
{ "default": { "description": "" } }
```

This keeps the generated document structurally valid without forcing every route to spell out a full response map. You can always override it by providing an explicit `responses` value.

```dart
// Minimal — Spry injects { "default": { "description": "" } } automatically
final openapi = OpenAPI(summary: 'Ping');

// Explicit — overrides the default
final openapi = OpenAPI(
  summary: 'Ping',
  responses: {
    '200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK')),
  },
);
```

## Reuse shared spec values

Spry resolves route-level `openapi` values through the Dart analyzer, not by evaluating raw JSON at runtime. This means any nested spec value can be extracted into shared Dart files and reused freely across routes.

Shareable at any nesting level:

- parameters, request bodies, responses
- security requirements
- schema definitions
- `globalComponents` buckets
- any field or sub-field, as long as the final resolved type comes from Spry's OpenAPI builders

Define shared values in a common file:

<<< ../snippets/reference/openapi/shared.dart

Then import and compose:

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
        description: 'User identifier.',
      ),
    ),
  ],
  responses: {
    '200': shared.userResponse,
    '401': OpenAPIRef.ref('#/components/responses/Unauthorized'),
  },
  security: [shared.bearerSecurity],
);
```

Spry accepts:

- direct `OpenAPI(...)` values
- references to top-level variables in the same or imported files
- deeply nested reuse — shared values that themselves reference other shared values

Spry rejects:

- raw map literals as the top-level `openapi` value (`final openapi = {...}`)
- local types shadowing Spry's OpenAPI builders (e.g. a locally defined `class OpenAPI`)
- values that don't ultimately resolve to Spry's typed builders

## Route-level globalComponents

Route files can contribute shared components using `globalComponents`:

<<< ../snippets/reference/openapi/routes.users_id.dart

These are lifted into the root `components` object during generation and do not appear nested inside the operation.

## Document-level components

Global shared components can also be declared directly in `spry.config.dart`:

```dart
OpenAPIDocumentConfig(
  info: OpenAPIInfo(title: 'Spry API', version: '1.0.0'),
  components: OpenAPIComponents(
    schemas: {
      'UserId': OpenAPISchema.string(description: 'Stable user identifier.'),
      'User': OpenAPISchema.object(
        {
          'id': OpenAPISchema.ref('#/components/schemas/UserId'),
          'name': OpenAPISchema.string(),
        },
        requiredProperties: ['id', 'name'],
      ),
    },
    securitySchemes: {
      'bearerAuth': OpenAPIRef.inline(
        OpenAPISecurityScheme.http(
          scheme: 'bearer',
          bearerFormat: 'JWT',
        ),
      ),
    },
    responses: {
      'Unauthorized': OpenAPIRef.inline(
        OpenAPIResponse(
          description: 'Missing or invalid credentials.',
        ),
      ),
    },
  ),
)
```

`OpenAPIComponents` supports all standard buckets:
`schemas`, `responses`, `parameters`, `examples`, `requestBodies`, `headers`, `securitySchemes`, `links`, `callbacks`, `pathItems`

## Refs and inline values

Most OpenAPI objects follow the inline-or-ref pattern using `OpenAPIRef<T>`:

```dart
responses: {
  '200': OpenAPIRef.inline(
    OpenAPIResponse(description: 'OK'),
  ),
  '404': OpenAPIRef.ref('#/components/responses/NotFound'),
  '500': OpenAPIRef.ref(
    '#/components/responses/InternalError',
    description: 'Override description for this operation.',
  ),
}
```

`OpenAPIPathItem` is the main exception — it carries `$ref` directly as a constructor parameter:

```dart
OpenAPIPathItem(
  $ref: '#/components/pathItems/UserCreatedWebhook',
)
```

## Build schemas

`OpenAPISchema` supports both JSON Schema object shapes and boolean schemas.

**Primitive types:**

```dart
OpenAPISchema.string(format: 'uuid', description: 'User ID.')
OpenAPISchema.integer(minimum: 1, maximum: 100)
OpenAPISchema.number()
OpenAPISchema.boolean()
OpenAPISchema.null_()
```

**Structured types:**

```dart
OpenAPISchema.object(
  {
    'id':       OpenAPISchema.string(),
    'name':     OpenAPISchema.string(),
    'nickname': OpenAPISchema.nullable(OpenAPISchema.string()),
    'role':     OpenAPISchema.ref('#/components/schemas/Role'),
  },
  requiredProperties: ['id', 'name'],
  additionalProperties: false,
)

OpenAPISchema.array(
  OpenAPISchema.ref('#/components/schemas/User'),
  minItems: 1,
)
```

**Composition:**

```dart
OpenAPISchema.oneOf([
  OpenAPISchema.ref('#/components/schemas/Cat'),
  OpenAPISchema.ref('#/components/schemas/Dog'),
])

OpenAPISchema.anyOf([
  OpenAPISchema.string(),
  OpenAPISchema.integer(),
])

OpenAPISchema.allOf([
  OpenAPISchema.ref('#/components/schemas/BaseEntity'),
  OpenAPISchema.object({'name': OpenAPISchema.string()}),
])
```

**Nullable (OpenAPI 3.1 `type: [T, "null"]`):**

```dart
OpenAPISchema.nullable(OpenAPISchema.string())
// → { "type": ["string", "null"] }
```

**Ref shorthand:**

```dart
OpenAPISchema.ref('#/components/schemas/User')
```

**Boolean schemas:**

```dart
OpenAPISchema.anything()  // true  — matches any value
OpenAPISchema.nothing()   // false — matches no value
```

**Escape hatch for non-standard keywords:**

```dart
OpenAPISchema.additional({
  'type': 'string',
  'x-ui-label': 'Display name',
})
```

## Parameters

Parameters are built with location-specific factories:

```dart
// Path parameter — always required
OpenAPIParameter.path(
  'id',
  schema: OpenAPISchema.ref('#/components/schemas/UserId'),
  description: 'User identifier.',
)

// Query parameter
OpenAPIParameter.query(
  'limit',
  schema: OpenAPISchema.integer(minimum: 1, maximum: 100),
  description: 'Maximum number of results.',
)

// Header parameter
OpenAPIParameter.header(
  'X-Request-Id',
  schema: OpenAPISchema.string(format: 'uuid'),
)

// Cookie parameter
OpenAPIParameter.cookie(
  'session',
  schema: OpenAPISchema.string(),
)
```

Each parameter requires either `schema` or `content`, but not both. When using `content`, provide exactly one media type entry.

## Request bodies

```dart
OpenAPIRequestBody(
  required: true,
  description: 'User creation payload.',
  content: {
    'application/json': OpenAPIMediaType(
      schema: OpenAPISchema.object(
        {
          'name':  OpenAPISchema.string(),
          'email': OpenAPISchema.string(format: 'email'),
        },
        requiredProperties: ['name', 'email'],
      ),
    ),
  },
)
```

## Responses

```dart
OpenAPIResponse(
  description: 'Created user.',
  headers: {
    'Location': OpenAPIRef.inline(
      OpenAPIHeader(
        schema: OpenAPISchema.string(),
        description: 'Canonical URL of the new resource.',
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

## Security

Security requirements attach at the document level (via `OpenAPIDocumentConfig.security`) or at the operation level:

```dart
final openapi = OpenAPI(
  summary: 'Create user',
  security: [
    OpenAPISecurityRequirement({'bearerAuth': []}),
  ],
);
```

Security schemes belong in `components.securitySchemes`. Available factories:

```dart
// API key — location: query | header | cookie
OpenAPISecurityScheme.apiKey(
  name: 'X-Api-Key',
  location: OpenAPIApiKeyLocation.header,
)

// HTTP — scheme: bearer, basic, digest, etc.
OpenAPISecurityScheme.http(
  scheme: 'bearer',
  bearerFormat: 'JWT',
)

// OAuth 2.0
OpenAPISecurityScheme.oauth2(
  flows: OpenAPIOAuthFlows(
    authorizationCode: OpenAPIOAuthFlow.authorizationCode(
      authorizationUrl: 'https://auth.example.com/authorize',
      tokenUrl: 'https://auth.example.com/token',
      scopes: {
        'users:read':  'Read user profiles',
        'users:write': 'Modify user profiles',
      },
    ),
  ),
)

// OpenID Connect
OpenAPISecurityScheme.openIdConnect(
  openIdConnectUrl:
      'https://auth.example.com/.well-known/openid-configuration',
)

// Mutual TLS
OpenAPISecurityScheme.mutualTLS()
```

OAuth flow factories: `.implicit(...)`, `.password(...)`, `.clientCredentials(...)`, `.authorizationCode(...)`

## Callbacks and webhooks

**Callbacks** are operation-level. They describe asynchronous requests that the server makes to a client-provided URL:

```dart
final openapi = OpenAPI(
  summary: 'Subscribe to events',
  callbacks: {
    'onEvent': OpenAPIRef.inline({
      '{$request.body#/callbackUrl}': OpenAPIPathItem(
        post: OpenAPIOperation(
          requestBody: OpenAPIRef.inline(
            OpenAPIRequestBody(
              content: {
                'application/json': OpenAPIMediaType(
                  schema: OpenAPISchema.ref('#/components/schemas/Event'),
                ),
              },
            ),
          ),
          responses: {
            '204': OpenAPIRef.inline(
              OpenAPIResponse(description: 'Received.'),
            ),
          },
        ),
      ),
    }),
  },
);
```

**Webhooks** are root-level and declared in `OpenAPIDocumentConfig.webhooks`:

```dart
OpenAPIDocumentConfig(
  info: OpenAPIInfo(title: 'Spry API', version: '1.0.0'),
  webhooks: {
    'userCreated': OpenAPIPathItem(
      post: OpenAPIOperation(
        requestBody: OpenAPIRef.inline(
          OpenAPIRequestBody(
            content: {
              'application/json': OpenAPIMediaType(
                schema: OpenAPISchema.ref('#/components/schemas/User'),
              ),
            },
          ),
        ),
        responses: {
          '202': OpenAPIRef.inline(OpenAPIResponse(description: 'Accepted.')),
        },
      ),
    ),
  },
)
```

Callbacks live under a specific operation. Webhooks live at the document root.

## Generation rules

Spry maps route files to OpenAPI operations using the filesystem routing model:

| Route file | OpenAPI path | Methods emitted |
|---|---|---|
| `routes/index.dart` | `/` | `get`, `post`, `put`, `patch`, `delete`, `options` |
| `routes/index.get.dart` | `/` | `get` only |
| `routes/users/[id].dart` | `/users/{id}` | `get`, `post`, `put`, `patch`, `delete`, `options` |
| `routes/users/[id].get.dart` | `/users/{id}` | `get` only |

Key rules:

- A method-less route expands to `get`, `post`, `put`, `patch`, `delete`, and `options`
- An explicit method file overrides just that method for the same path; the method-less expansion fills the rest
- `HEAD` is only emitted when a route explicitly has a `.head.dart` suffix — the runtime `HEAD → GET` fallback is intentionally not mirrored into OpenAPI
- `TRACE` is never emitted
- Route path params are converted to OpenAPI `{param}` syntax (e.g. `:id` → `{id}`)
- Every `{param}` in the path is guaranteed to appear in the operation's `parameters` list; undeclared parameters receive a minimal auto-generated stub with `required: true` (OAS 3.1 mandates this for all path parameters). Explicitly declared parameters are kept as-is

## Components merge strategy

When route files contribute `globalComponents`, Spry merges them with document-level `components`.

**`OpenAPIComponentsMergeStrategy.strict`** (default)

- Identical definitions for the same component name are deduplicated silently
- Conflicting definitions (same name, different shape) fail the build with an error that names both contributing sources

**`OpenAPIComponentsMergeStrategy.deepMerge`**

- Map-shaped values with the same component name are merged recursively
- Conflicting leaf values (same key path, different primitive values) still fail the build

```dart
OpenAPIConfig(
  document: ...,
  componentsMergeStrategy: OpenAPIComponentsMergeStrategy.deepMerge,
)
```

## Output location

| Factory | Effect |
|---|---|
| `OpenAPIOutput.route('openapi.json')` | Written to `public/openapi.json` — served as a static asset at `/openapi.json` |
| `OpenAPIOutput.local('docs/openapi.json')` | Written to `<project-root>/docs/openapi.json` |

The default output is `OpenAPIOutput.route('openapi.json')`.
