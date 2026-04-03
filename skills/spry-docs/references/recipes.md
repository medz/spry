# Spry Docs Recipes

## Table of contents

- [Project layout and source of truth](#project-layout-and-source-of-truth)
- [Add or change a route](#add-or-change-a-route)
- [Choose global vs scoped middleware or error handling](#choose-global-vs-scoped-middleware-or-error-handling)
- [Configure OpenAPI output](#configure-openapi-output)
- [Configure client generation](#configure-client-generation)
- [Change runtime target or deploy output](#change-runtime-target-or-deploy-output)
- [Decide when to inspect generated `.spry/` output](#decide-when-to-inspect-generated-spry-output)
- [Validation checklist](#validation-checklist)

## Project layout and source of truth

Start with the app tree before inspecting framework internals:

- `spry.config.dart` confirms `routesDir`, `middlewareDir`, `publicDir`,
  `outputDir`, target, and build behavior.
- `routes/` contains handlers plus scoped `_middleware.dart` and `_error.dart`.
- `middleware/` contains global middleware collected in filename order.
- `public/` contains static assets served directly.
- `hooks.dart` contains startup and shutdown hooks.
- `.spry/` contains generated output from `spry serve` or `spry build`.

Read the docs before inspecting implementation details:

- `README.md`
- `sites/spry.medz.dev/getting-started.md`
- `sites/spry.medz.dev/guide/app.md`
- `sites/spry.medz.dev/guide/routing.md`
- `sites/spry.medz.dev/guide/openapi.md`
- `sites/spry.medz.dev/guide/client.md`
- `sites/spry.medz.dev/config.md`
- `sites/spry.medz.dev/deploy/index.md`

Use framework source only when the docs, app tree, and generated output still
leave behavior unexplained.

## Add or change a route

Start with:

- `spry.config.dart` to confirm `routesDir`
- `sites/spry.medz.dev/getting-started.md`
- `sites/spry.medz.dev/guide/routing.md`

Common mappings:

- `routes/index.dart` -> `/`
- `routes/about.get.dart` -> `GET /about`
- `routes/users/[id].dart` -> `/users/:id`
- `routes/[...slug].dart` -> `/**:slug`

Use these examples when you want a known-good pattern:

- `example/dart_vm/routes/index.dart`
- `example/dart_vm/routes/about.get.dart`
- `example/dart_vm/routes/[...slug].dart`

Validate with:

```bash
dart run spry serve
```

Also run `dart run spry build` when emitted runtime output matters.

## Choose global vs scoped middleware or error handling

Read:

- `sites/spry.medz.dev/guide/app.md`
- `sites/spry.medz.dev/guide/routing.md`
- `sites/spry.medz.dev/guide/handler.md`

Use:

- `middleware/` for global behavior collected in filename order
- `routes/**/_middleware.dart` for branch-local behavior
- `routes/**/_error.dart` for branch-local error mapping
- `defineHandler(...)` when middleware or error handling belongs to one route

Helpful examples:

- `example/dart_vm/middleware/01_logger.dart`
- `example/dart_vm/routes/_middleware.dart`
- `example/dart_vm/routes/_error.dart`

If behavior still looks wrong after checking docs and app files, inspect:

- `lib/src/middleware.dart`
- `lib/src/middleware/combine.dart`
- `lib/src/errors.dart`
- `lib/src/app.dart`

## Configure OpenAPI output

Read:

- `sites/spry.medz.dev/guide/openapi.md`
- `sites/spry.medz.dev/config.md`

Key rules:

- `spry.config.dart` seeds the document and chooses output
- route files expose top-level `openapi` values for operation metadata
- Spry derives `paths` from the filesystem; do not hand-write them

Useful references:

- `sites/spry.medz.dev/snippets/reference/openapi/spry.config.dart`
- `sites/spry.medz.dev/snippets/reference/openapi/routes.index.dart`
- `sites/spry.medz.dev/snippets/reference/openapi/shared.dart`
- `example/openapi/`

Inspect generated output only when you need to verify the merged document or the
generated route artifact.

## Configure client generation

Read:

- `sites/spry.medz.dev/guide/client.md`
- `example/client_example/README.md`

Key rules:

- route metadata is enough to generate a client
- OpenAPI metadata improves request and response typing, but client generation
  does not require `openapi.output`

Useful commands:

```bash
dart run spry build
dart run spry build client
```

Useful files:

- `example/client_example/server/spry.config.dart`
- `example/client_example/server/routes/`
- `example/client_example/client/lib/`

Inspect generated client files when the task is about output naming, type
generation, or how route metadata became code.

## Change runtime target or deploy output

Read:

- `sites/spry.medz.dev/config.md`
- `sites/spry.medz.dev/deploy/index.md`
- the matching target page under `sites/spry.medz.dev/deploy/`

Check:

- `spry.config.dart` `target`
- `ReloadStrategy` when the local dev loop matters
- `outputDir` or target-specific config such as `wranglerConfig`

Smoke-test with the matching example when you touch target-specific behavior:

- `example/dart_vm/`
- `example/node/`
- `example/bun/`
- `example/deno/`
- `example/cloudflare/`
- `example/vercel/`
- `example/netlify/`

## Decide when to inspect generated `.spry/` output

Inspect `.spry/` or the configured output directory when:

- a route or middleware exists in source but behaves differently at runtime
- OpenAPI or client artifacts are missing, stale, or named unexpectedly
- a target wrapper for Node, Bun, Deno, Cloudflare, Vercel, or Netlify looks
  wrong
- the task is about emitted files rather than authored source

Do not inspect generated output first when the task is only about how to author
routes, middleware, or config.

## Validation checklist

For most Spry app changes:

```bash
dart format .
dart analyze
dart run spry serve
dart run spry build
```

Only run client generation when relevant:

```bash
dart run spry build client
```

If you think you found a framework bug, capture:

- the relevant `spry.config.dart`
- the route or middleware file path
- the runtime target
- the generated `.spry/` artifact that looks wrong
