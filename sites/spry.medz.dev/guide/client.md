---
title: Guide → Client
description: Generate a Spry Client from route metadata, then optionally enhance it with OpenAPI-driven types.
---

# Client

Spry Client is a generated client layer built from your Spry app.

It always starts from route metadata, so it can be generated even when you do not export `openapi.json`.
OpenAPI only enhances the client with stronger request and response types.

## Mental model

Think about Spry Client in two layers:

- **route metadata** gives Spry enough information to generate a callable client
- **OpenAPI metadata** adds typed inputs, queries, headers, outputs, and shared models

That means:

- you do not need to hand-write endpoints in the client
- you do not need to enable OpenAPI artifact output to generate a client
- you only need OpenAPI when you want stronger types

## Configure client generation

Client generation is configured in `spry.config.dart`:

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    target: .vm,
    client: .new(
      pkgDir: '.spry/client',
      output: 'lib',
      endpoint: 'https://api.example.com',
      headers: .new({'x-client': 'web'}),
    ),
  );
}
```

### ClientConfig fields

| Field | Description |
|---|---|
| `pkgDir` | Package root for the generated client. Defaults to `.spry/client`. |
| `output` | Output directory for generated Dart code. Defaults to `lib`. When `pkgDir` is set, this path is resolved relative to that package directory. |
| `endpoint` | Default endpoint embedded into the generated `SpryClient`. It can still be overridden at runtime. |
| `headers` | Static default global headers embedded into the generated `SpryClient`. |

Two header layers exist intentionally:

- `client.headers` in `spry.config.dart` embeds static defaults into generated code
- `SpryClient(headers: ...)` provides per-request runtime headers, such as tokens

## Build commands

Spry Client lives under the normal build flow:

```bash
dart run spry build
dart run spry build client
```

Use them like this:

- `spry build` builds the app and also builds the client when `client` is configured
- `spry build client` only builds the client artifact

Client generation does **not** depend on OpenAPI artifact output.

In other words, this is valid:

- route files contain `openapi` metadata for type enhancement
- no `openapi.output` is configured
- `spry build client` still generates a typed client

## Output layout

Spry generates a thin client package. The shared runtime stays in `package:spry/client.dart`.

Typical output looks like this:

```text
client/
├─ lib/
│  ├─ client.dart
│  ├─ routes.dart
│  ├─ params.dart
│  ├─ inputs.dart
│  ├─ headers.dart
│  ├─ queries.dart
│  ├─ outputs.dart
│  ├─ models.dart
│  ├─ routes/
│  ├─ params/
│  ├─ inputs/
│  ├─ headers/
│  ├─ queries/
│  ├─ outputs/
│  └─ models/
└─ pubspec.yaml
```

The generated directories follow different rules:

- `routes/` mirrors route pathname structure
- `params/` mirrors route pathname structure
- `inputs/`, `headers/`, `queries/`, and `outputs/` mirror route file semantics and keep method suffixes when needed
- `models/` contains shared component schemas lifted from `#/components/schemas/*`

## Generate into a standalone package

This is the simplest setup when you want a dedicated generated client package:

```dart
client: .new(
  pkgDir: '.spry/client',
  output: 'lib',
  endpoint: 'http://127.0.0.1:4020',
)
```

When `pkgDir/pubspec.yaml` does not exist, Spry creates a minimal package shell first.

This setup works well when:

- you want a generated client package next to the server
- you want to publish or share the client separately later
- you want a clean boundary between server code and generated client code

## Generate into an existing package

You can also generate the client into an existing Dart or Flutter package:

```dart
client: .new(
  pkgDir: '../app',
  output: 'lib/generated/spry',
  endpoint: 'https://api.example.com',
)
```

This setup works well when:

- your app already has a package root
- you want generated files to live under `lib/generated/...`
- you want handwritten code and generated code in the same package

The important distinction is:

- `pkgDir` points to the package root
- `output` points to the generated code directory inside that package

## Generated client shape

The generated entrypoint looks like a normal runtime object:

```dart
import 'package:example_client/client.dart';

final client = SpryClient();
```

Generated route helpers are namespace-oriented:

```dart
final created = await client.users(
  data: PostUsersInput(name: 'Seven'),
);

final user = await client.users.byId(
  params: UsersByIdParams(id: 'u_1'),
);
```

The generated runtime keeps fetch-like escape hatches in the same call signature:

- `data` for typed JSON input
- `body` for raw request body
- `headers` for request-level header overrides
- `query` for request-level query overrides

`body` still wins over `data`.

## OpenAPI enhancement

OpenAPI does not create the client. It enhances the client.

When route metadata includes useful OpenAPI information, Spry can generate:

- `*Input` for safe JSON request bodies
- `*Query` for query parameters
- `*Headers` for header parameters
- `*Output` for safe single-success JSON responses
- shared `models/*` for `#/components/schemas/*`

When OpenAPI information is missing or incomplete:

- the client is still generated
- request typing becomes weaker
- response typing falls back to `Response`

### Request body typing

Only safe JSON request bodies are typed.

For example, a route with a JSON body can generate:

```dart
await client.users(
  data: PostUsersInput(name: 'Seven'),
);
```

Non-JSON request bodies do not generate `*Input`.
In those cases, keep using raw `body:`.

### Query typing

If a route defines OpenAPI query parameters, Spry generates a typed query helper:

```dart
final query = GetSearchQuery(
  q: 'spry',
  page: 2,
  startsAt: DateTime.now(),
);
```

It also keeps a raw constructor for advanced cases:

```dart
final query = GetSearchQuery.raw({'q': 'spry'});
```

### Header typing

Header generation follows the same pattern:

```dart
final headers = GetProfileHeaders(
  xApiKey: 'secret',
  xRequestId: 'req_123',
);
```

And still exposes:

```dart
final headers = GetProfileHeaders.raw({'x-api-key': 'secret'});
```

### Output typing

When a route has a safe single-success JSON response, Spry generates a route-local `*Output`.

That object is not just a plain DTO. It also keeps access to the original response:

```dart
final output = await client.root();
final response = output.toResponse();
```

### Shared models

Shared component schemas keep their declared names.

For example:

- `#/components/schemas/Participant` becomes `Participant`
- `#/components/schemas/Address` becomes `Address`

These types are generated into `models/` and re-exported through `models.dart`.

## Where to start

If you want to inspect a real generated client, use the dedicated example:

- [Client Example](https://github.com/medz/spry/tree/main/example/client_example)

Start with these files:

- [server/spry.config.dart](https://github.com/medz/spry/blob/main/example/client_example/server/spry.config.dart)
- [client/lib/client.dart](https://github.com/medz/spry/blob/main/example/client_example/client/lib/client.dart)
- [client/lib/routes/users/index.dart](https://github.com/medz/spry/blob/main/example/client_example/client/lib/routes/users/index.dart)
- [client/lib/queries/search/index.get.dart](https://github.com/medz/spry/blob/main/example/client_example/client/lib/queries/search/index.get.dart)
- [client/lib/headers/profile/index.get.dart](https://github.com/medz/spry/blob/main/example/client_example/client/lib/headers/profile/index.get.dart)

## Next steps

After the client shape looks right:

1. keep route metadata authoritative
2. add OpenAPI only where stronger types improve DX
3. choose whether the client should live in a standalone package or an existing package
4. build with `spry build client` during local iteration
